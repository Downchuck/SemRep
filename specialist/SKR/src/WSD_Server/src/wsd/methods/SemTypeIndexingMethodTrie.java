//=== File Prolog ==========================================================
//    This code was developed for National Library of Medicine, Cognitive
//    Science Branch
//
//--- Notes ----------------------------------------------------------------
//
//
//--- Development History --------------------------------------------------
//    Date        Author             Reference
//    ----        ------             ---------
//    06/27/06    Willie Rogers    Initial Version
//
//--- Warning --------------------------------------------------------------
//    This software is property of the National Library of Medicine.
//    Unauthorized use or duplication of this software is
//    strictly prohibited.  Authorized users are subject to the following
//    restrictions:
//    *   Neither the author, their corporation, nor NLM is responsible for
//        any consequence of the use of this software.
//    *   The origin of this software must not be misrepresented either by
//        explicit claim or omission.
//    *   Altered versions of this software must be plainly marked as such.
//    *   This notice may not be removed or altered.
//
//=== End File Prolog ======================================================
package wsd.methods;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.StreamTokenizer;
import java.util.*;
import java.util.zip.GZIPInputStream;
import java.util.zip.GZIPOutputStream;
import java.util.regex.Pattern;

import org.apache.log4j.Logger;

import org.jdom.Document;
import org.jdom.Element;
import org.jdom.Namespace;

import wsd.model.*;
import wsd.WSDEnvironment;
// import wsd.util.IntArrayIndex;
// import wsd.util.IntArrayBinSearchPool;
import gov.nih.nlm.nls.utils.StringUtils;
import gov.nih.nlm.nls.util.trie.Trie;
import java.text.DecimalFormat;

/**
 * Implementation of Semantic Type Indexing in Java.  Based on Susanne
 * Humphrey's semantic-type4 function originally implemented in Lisp.
 * Sussanne's tables have been tranferred to inverted files
 * implemented using binary search table partitioned by term length
 * generated by the module java class wsd.util.IntArrayIndex.
 *
 * <P>This code was developed for National Library of Medicine, Cognitive
 * Science Branch.
 *
 * <p>$Id: SemTypeIndexingMethod.java,v 1.17 2008/05/08 17:36:59 wrogers Exp $</p>
 *
 * <p>Description: Word Sense Disambiguation</p>
 *
 * @version  27jun2006
 * @author   Willie Rogers
 */
public class SemTypeIndexingMethodTrie implements DisambiguationMethod
{
  /** which database to use this should be added to server configuration file */
  /** size of semantic type (ST) feature vectors */
  public static final int STVECTORSIZE = 129;
  /** table of semantic type names in order of their occurance within ST feature vectors */
  public static final String stAbbrev[] = {
    "aapp","acab","acty","aggp","alga","amph","anab","anim","anst","antb",
    "arch","bacs","bact","bdsu","bdsy","bhvr","biof","bird","blor","bmod",
    "bodm","bpoc","bsoj","carb","celc","celf","cell","cgab","chem","chvf",
    "chvs","clas","clna","clnd","cnce","comd","diap","dora","dsyn","edac",
    "eehu","eico","elii","emod","emst","enzy","evnt","famg","ffas","fish",
    "fndg","fngs","food","ftcn","genf","geoa","gngm","gora","grpa","grup",
    "hcpp","hcro","hlca","hops","horm","humn","idcn","imft","inbe","inch",
    "inpo","inpr","invt","irda","lang","lbpr","lbtr","lipd","mamm","mbrt",
    "mcha","medd","menp","mnob","mobd","moft","neop","nnon","npop","nsba",
    "nusq","ocac","ocdi","opco","orch","orga","orgf","orgm","orgt","ortf",
    "patf","phob","phpr","phsf","phsu","plnt","podg","popg","prog","qlco",
    "qnco","rcpt","rept","resa","resd","rich","rnlw","sbst","shro","socb",
    "sosy","spco","strd","tisu","tmco","topp","virs","vita","vtbt"
  };
  /** string containing known punctuation */
  public static final String PUNCTUATION = "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~";
  /** string containing known whitespace */
  public static final String WHITESPACE = " \t\n\r\f";
  /** Logger for this class */
  private static Logger logger = Logger.getLogger(SemTypeIndexingMethodTrie.class);
  /** set format for scores in test method */
  private static DecimalFormat scoreFormat = new DecimalFormat("0.0000");
  /** Filename for Berkeley DB Term/STI score file used by Semantic Type Indexing Method */
  public static String fSemanticTypeIndexingIndexFilePath =
    WSDEnvironment.properties.getProperty("DISAMB_SERVER_STI_INDEXPATH"); // STI-IF Method
  /** file containing list of allowed words */
  public static String fSemanticTypeIndexingIndexRestrictWordsFile =
    WSDEnvironment.properties.getProperty("DISAMB_SERVER_STI_RESTRICTWORDSFILE", "restrictwords.txt");
  /** file containing list of not allowed words */
  public static String fSemanticTypeIndexingIndexStopWordsFile =
    WSDEnvironment.properties.getProperty("DISAMB_SERVER_STI_STOPWORDSFILE", "stopwords.txt");
  public static String fSemanticTypeIndexingIndexTrainingFile =
    WSDEnvironment.properties.getProperty("DISAMB_SERVER_STI_TRAININGFILE", "wstvsc01-12-dc.txt");
  /** list of allowed words */
  public static Set restrictwords;
  /** list of not allowed words */
  public static Set stopwords;
  private static Pattern p = Pattern.compile(" ");
  public static Trie <int []> termTrie;
  static {
    restrictwords = loadWordSet(fSemanticTypeIndexingIndexRestrictWordsFile);
    stopwords = loadWordSet(fSemanticTypeIndexingIndexStopWordsFile);
    try {
      termTrie = loadTrie(fSemanticTypeIndexingIndexTrainingFile);
    } catch (FileNotFoundException e) {
      logger.error(e.getMessage());
      
    } catch (IOException e) {
      logger.error(e.getMessage());
    }
    logger.info("SemTypeIndexingMethodTrie:class init: STI class initialized");
  }

  public SemTypeIndexingMethodTrie() 
  {
   logger.info("SemTypeIndexingMethodTrie:instance init: STI instance initialized");
  }

  /**
   * Get serialized Trie instance if available.
   * @param file name of file plus ".ser.gz" containing serialized instance.
   * @return Trie instance or null if file does not exist.
   */
  private static Trie <int []> getSerializedTrie(String file)
  {
    Trie <int []> trie = null;
    try {
	ObjectInputStream o = new ObjectInputStream(new GZIPInputStream(new FileInputStream(file + ".ser.gz")));
	trie = (Trie <int []>)o.readObject();
	o.close();
      } catch (Exception e) {
      logger.info(e.getMessage() + " attempting to read Serialized trie structure in file: " + file + ".ser.gz");
    }
    return trie;
  }

  /**
   * load Trie instance from serialized object file or flat file.
   * @param file name of flat file (serialized file has added extension ".ser.gz") for Trie instance.
   * @return Trie instance
   */
  public static Trie <int []> loadTrie(String filename)
    throws FileNotFoundException, IOException
  {
    Trie <int []> trie = getSerializedTrie(filename);
    // If no serialization
    if (trie == null)
      {
	trie = new Trie <int []> ();
	logger.info("Loading...");
	BufferedReader b = new BufferedReader(new FileReader(filename));
	String line;
	int i = 0;
	while ((line = b.readLine()) != null)
	  {
	    String [] tokens = p.split(line);
	    int [] vector = new int [129];
	    for (int j=1; j < tokens.length; j++)
	      {	vector[j-1] = Integer.parseInt(tokens[j]); }		
	    trie.insert(tokens[0], vector); 
	    if (i % 10000 == 0) logger.info(i);
	    i++;
	  }
	b.close();
	logger.info("Loaded all the terms!");
	// Store a serialized version of the trie structure
	logger.info("Writing serialized trie structure to file: " + filename + ".ser.gz");
	ObjectOutputStream o = new ObjectOutputStream(new GZIPOutputStream(new FileOutputStream(filename + ".ser.gz")));
	o.writeObject(trie);
	o.close();
      }
    return trie;
  }

  public static Set loadWordSet(String filename)
  {
    Set wordSet = new HashSet();
    try {
      StreamTokenizer st = 
        new StreamTokenizer(new BufferedReader(new FileReader(filename)));
      while(st.nextToken() != StreamTokenizer.TT_EOF) {
        if (st.ttype == StreamTokenizer.TT_WORD)
          wordSet.add(st.sval);
      }
    } catch (FileNotFoundException e) {
      logger.error("loadWordSet:" + e.getMessage(), e);
    } catch (IOException e) {
      logger.error("loadWordSet:" + e.getMessage(), e);
    }
    return wordSet;
  }

  public static boolean isRestrictWord(String term)
  {
    return restrictwords.contains(term.toUpperCase());
  }

  public static boolean notStopWord(String term)
  {
    return (! stopwords.contains(term.toUpperCase()));
  }

  /** Susanne's modification removing QLCO and FNDG from pair of STs for a
      concept.*/
  public static List removeGeneralSemtypesFromPairs(List semanticTypes)
  {
    if (semanticTypes.size() <= 1) 
      return semanticTypes;
    List specificSemanticTypes = new ArrayList();
    for (int i=0; i < semanticTypes.size(); i++)
      {
        String semTypeAbbrev = (String)semanticTypes.get(i);
        if ((semTypeAbbrev != "qlco") && (semTypeAbbrev != "fndg"))
          specificSemanticTypes.add(semTypeAbbrev);
      }
    if (specificSemanticTypes.size() == 0)
      return semanticTypes;
    else
      return specificSemanticTypes;
  }

  /**
   * 
   */
  public void finalize()
  {
  }

  /**
   * Get Match
   *
   * @param doc XML DOM representation of document
   * @return list of Result objects
   */
  public List getMatch(Document doc)
  {
    List jdResults = new Vector();
    Element root = doc.getRootElement();
    Namespace ns = root.getNamespace();

    if (logger.isInfoEnabled())
      logger.info("Disambiguating using STI Method.");
    //get the utterance list
    List utteranceList = root.getChildren("utterance", ns);
    ListIterator utteranceIterator = utteranceList.listIterator();
    while (utteranceIterator.hasNext())
      {
        Element utteranceNode = (Element)utteranceIterator.next();
        Utterance utterance = new Utterance(utteranceNode,ns);

        //get the noun phrase list
        List phraseList = utteranceNode.getChildren("phrase",ns);
        ListIterator phraseIterator = phraseList.listIterator();
        while (phraseIterator.hasNext())
          {
            Element phraseNode = (Element)phraseIterator.next();
            NounPhrase nounPhrase = new NounPhrase(phraseNode,ns);
            if (phraseNode.hasChildren())
              {
                //get the ambiguity list
                Element ambiguitiesNode = phraseNode.getChild("ambiguities",ns);
                List ambiguityList = ambiguitiesNode.getChildren("ambiguity",ns);
                ListIterator ambiguityIterator = ambiguityList.listIterator();
                while (ambiguityIterator.hasNext())
                  {
                    Element ambiguityNode = (Element)ambiguityIterator.next();
                    Ambiguity ambiguity = new Ambiguity(ambiguityNode,ns);
                    //if the ambiguity is marked to be "process"ed, process it
                    //otherwise skip.
                    if (ambiguity.getNeedProcessing())
                      {
                        List candidateList = ambiguityNode.getChildren("candidate",ns);
                        ListIterator candidateIterator = candidateList.listIterator();
                        PreferredNameVector prefNames = new PreferredNameVector();
                        List candidates = new Vector();
                        Candidate candidate = new Candidate();
                        while (candidateIterator.hasNext())
                          {
                            Element candidateNode = (Element)candidateIterator.next();
                            candidate = new Candidate(candidateNode,ns);
                            candidates.add(candidate);
                            String preferredName = candidate.getPreferredConceptName();
                            prefNames.add(preferredName);
                          }
                        List<String> context = getContext(doc,utterance,candidate.getMatchedWords());
                        List bestPrefNames = this.getMatch(utterance,null,context,candidates);
                        //create the Result object that stores the ambiguity result data
                        if (bestPrefNames.size() > 0) {
                          if (bestPrefNames.get(0) instanceof String) {
                            if (bestPrefNames.get(0).equals("NIL")) {
                              jdResults = null;
                            } else if (bestPrefNames.get(0).equals("[Error STI inputstring is empty or null]")) {
                              jdResults = null;
                            } else if (((String)bestPrefNames.get(0)).startsWith("[Error STI condition:")) {
                              Result res = new Result();
                              res.setCandidatePreferredConceptNames(prefNames);
                              res.setPreferredConceptNames(bestPrefNames);
                              res.setUi(utterance.getUi());
                              res.setUtterancePos(utterance.getPos());
                              res.setPhrasePos(nounPhrase.getPos());
                              jdResults.add(res);
                            } else if (((String)bestPrefNames.get(0)).equals("[Warning: STI unable to disambiguate input]")) {
                              jdResults = null;
                            } else {
                              Result res = new Result();
                              res.setCandidatePreferredConceptNames(prefNames);
                              res.setPreferredConceptNames(bestPrefNames);
                              res.setUi(utterance.getUi());
                              res.setUtterancePos(utterance.getPos());
                              res.setPhrasePos(nounPhrase.getPos());
                              jdResults.add(res);
                              if (logger.isDebugEnabled())
                                logger.debug("Result: " + res.getUi() + "|" +
                                             res.getUtterancePos() + "|" +
                                             res.getPhrasePos() + "|" +
                                             res.getCandidatePreferredConceptNames() + "|" +
                                             res.getPreferredConceptNames());
                            }
                          } else {
                            Result res = new Result();
                            res.setCandidatePreferredConceptNames(prefNames);
                            res.setPreferredConceptNames(bestPrefNames);
                            res.setUi(utterance.getUi());
                            res.setUtterancePos(utterance.getPos());
                            res.setPhrasePos(nounPhrase.getPos());
                            jdResults.add(res);
                            if (logger.isDebugEnabled())
                              logger.debug("Result: " + res.getUi() + "|" +
                                           res.getUtterancePos() + "|" +
                                           res.getPhrasePos() + "|" +
                                           res.getCandidatePreferredConceptNames() + "|" +
                                           res.getPreferredConceptNames());
                          }
                        }
                      }
                  }
              }
          }
      }
    if (logger.isInfoEnabled())
      logger.info("Completed disambiguation using STI Method.");
    return jdResults;
  }

  private List<String> getContext(Document doc, Utterance currUtterance, String wordlist)
  {
      List<String> context = new Vector<String>();
      List<String> words = new Vector<String>();
      String currSentence = currUtterance.getSentence();
      // StringTokenizer tokenizer = new StringTokenizer(wordlist,",");
      // while (tokenizer.hasMoreTokens())
      //  words.add(((String)tokenizer.nextToken()).toLowerCase());
      Element root = doc.getRootElement();
      Namespace ns = root.getNamespace();

      if (logger.isInfoEnabled())
        logger.info("Computing context.");
      //get the utterance list
      List<Element> utteranceList = root.getChildren("utterance", ns);
      ListIterator utteranceIterator = utteranceList.listIterator();
      while (utteranceIterator.hasNext())
        {
          Element utteranceNode = (Element)utteranceIterator.next();
 	  Utterance utterance = new Utterance(utteranceNode,ns);
          context.add(utterance.getSentence());
          if (logger.isDebugEnabled())
            logger.debug("added to context: " + utterance.getSentence());
        }
      if (logger.isDebugEnabled())
        logger.debug("The context is:" + context.toString());
      return context;
  }

  // debug
  public void logStiResult(int[] resultVector, int topN)
  {
    SortedMap resultMap = mapStiResult(resultVector);
    int i = 0;
    Iterator mapIterator = resultMap.keySet().iterator();
    while (mapIterator.hasNext() && i < topN) {
      Integer score = (Integer)mapIterator.next();
      logger.debug( score + " " + resultMap.get(score));
      i++;
    }
  }

  public void logStiResultWideFormat(int[] resultVector, int topN)
  {
    StringBuffer sb = new StringBuffer();
    sb.append("ranks: ");
    SortedMap resultMap = mapStiResult(resultVector);
    int i = 0;
    Iterator mapIterator = resultMap.keySet().iterator();
    while (mapIterator.hasNext() && i < topN) {
      Integer score = (Integer)mapIterator.next();
      sb.append( score + ":" + resultMap.get(score) + " ");
      i++;
    }
    logger.debug( sb.toString() );
  }

  public void logStiResult(int[] resultVector, List semtypes)
  {
    StringBuffer sb = new StringBuffer();
    sb.append("ranks: ");
    SortedMap resultMap = mapStiResultBySemType(resultVector);
    int i = 0;
    ListIterator semtypeIterator = semtypes.listIterator();
    while (semtypeIterator.hasNext()) {
      String semtype = (String)semtypeIterator.next();
      sb.append( semtype + ":" + resultMap.get(semtype) + " ");
      i++;
    }
    logger.debug( sb.toString() );
  }


  // end debug


  /**
   * Calls the STI Method and finds the best match in the list of concepts.
   *
   * The semantic type with the highest score is used and first Candidate
   * encountered that has semantic type is returned, the other candidates
   * are discarded.
   *
   * @see wsd.methods.JdDisambiguator.buildLispSexpMessage
   *
   * @param utterance   The sentence or fragment containing the ambiguity.
   * @param phrases     The phrases in the utterance.
   * @param context     the context of the ambiguity. Initial thought was to have
   *                    several sentences associated with the ambiguity as the context.
   * @param candidates  List of WordSenses of the concepts that cause the ambiguity
   *
   * @return a Result object that represents the best match from STI method
   * @see wsd.model.WordSense
   */
  public List<String> getMatch(Utterance utterance, List phrases, List context, List candidates)
  {
    StringBuffer sbuf = new StringBuffer();
    sbuf.append(utterance.getSentence().replaceAll("\"","")).append(" ");
    Iterator contextIter = context.iterator();
    while (contextIter.hasNext()) 
      sbuf.append(contextIter.next()).append(" ");
    if (logger.isDebugEnabled())
      logger.debug("calling calculateStiProfileVector(\"" + sbuf + "\")");

    int[] stiResultVector = this.calculateStiProfileVector(sbuf.toString());
    List semTypes = new ArrayList();
    Iterator candidateIterator = candidates.iterator();
    while (candidateIterator.hasNext()) {
      Candidate candidate = (Candidate)candidateIterator.next();
      List candidateSemTypes = removeGeneralSemtypesFromPairs(candidate.getSemTypes());
      for (int i=0; i < candidateSemTypes.size(); i++)
        {
          String semTypeAbbrev = (String)candidateSemTypes.get(i);
          semTypes.add(semTypeAbbrev);
        }
    }
    if (logger.isDebugEnabled())
      logger.debug("candidate semantic types = " + semTypes );
    if (logger.isDebugEnabled())
      logStiResult(stiResultVector, semTypes);
    String resultSemtype = pickBestSemType(stiResultVector, semTypes);
    if (logger.isDebugEnabled())
      logger.debug("semantic types returned from method = " + resultSemtype );
    List<String> resultConcepts = new Vector<String>();
    if (resultSemtype == null) {
      resultConcepts.add("STI unable to disambiguate input");
    } else {
      boolean done = false;
      for (int j=0; j < candidates.size() && done == false; j++)
        {
          if (((Candidate)candidates.get(j)).getSemTypes().contains(resultSemtype))
            {
              resultConcepts.add(((Candidate)candidates.get(j)).getPreferredConceptName());
              if (logger.isDebugEnabled())
                logger.debug(utterance.getUi() + 
                             ":, " + resultSemtype + 
                             ", added: " + candidates.get(j) + ", " + done);
              done = true;	// only add one candidate that matches semantic type, drop the others.
              break;
            }
        }
    }
    return resultConcepts;
  }

  /**
   * Calculate Semantic Type Indexing Vector for supplied tokenized
   * term list.
   *
   * @param token list of tokenized terms to be profiled.
   * @return array of ints representing profile vector
   */
  public int[] calculateStiProfileVector(List tokens)
  {
    int resultVector[] = new int[STVECTORSIZE];
    int sumVector[]    = new int[STVECTORSIZE];
    int termVector[]   = new int[STVECTORSIZE];
    ListIterator st = tokens.listIterator();
    int count = 0;
    while (st.hasNext()) {
      String term = (String)st.next();
      if (isRestrictWord(term) && notStopWord(term)) {
	// get vector for term
	termVector = this.termTrie.get(term.toUpperCase());
        if (termVector != null) {
          count++;
          for (int i = 0; i<STVECTORSIZE; i++) {    
            sumVector[i] = sumVector[i] + termVector[i];
          }
        }
      }
    }
    if (count != 0) {
      for (int i = 0; i<STVECTORSIZE; i++) {    
        resultVector[i] = sumVector[i]/count;
      }
    }
    return resultVector;
  }

  /**
   * Calculate Semantic Type Indexing Vector for supplied phrase
   *
   * @param phrase phrase to be profiled.
   * @return array of ints representing profile vector
   */
  public int[] calculateStiProfileVector(String phrase)
  {
    StringBuffer sb = new StringBuffer();
    int resultVector[] = new int[STVECTORSIZE];
    int sumVector[]    = new int[STVECTORSIZE];
    int termVector[]   = new int[STVECTORSIZE];
    StringTokenizer st = new StringTokenizer(phrase, this.PUNCTUATION + this.WHITESPACE);
    int count = 0;
    while (st.hasMoreTokens()) {
      String term = st.nextToken();
      if (isRestrictWord(term) && notStopWord(term)) {
	// get vector for term
	termVector = this.termTrie.get(term.toUpperCase());
        if (termVector != null) {
          count++;
          for (int i = 0; i<STVECTORSIZE; i++) {    
            sumVector[i] = sumVector[i] + termVector[i];
          }
	}
      }
    }
    if (count != 0) {
      for (int i = 0; i<STVECTORSIZE; i++) {
        resultVector[i] = sumVector[i]/count;
      }
    }
    return resultVector;
  }

  /**
   * Generate a sorted map of result by score (key) -> semantic type (value).
   * 
   * @param resultvector 
   * @return sorted map of result vector
   */
  public SortedMap mapStiResult(int[] resultVector)
  {
    // the supplied anonymous comparator sorts the result by score in reverse order.
    SortedMap resultMap = new TreeMap(new Comparator() {
	public int compare(Object o1, Object o2) {
	  int cc = ((Integer)o1).compareTo((Integer)o2);
	  return (cc < 0 ? 1 : cc > 0 ? -1 : 0);
	}
      });
    // load scores into Sorted Map with associated semantic type name.
    for (int i = 0; i<STVECTORSIZE; i++) {
      resultMap.put(new Integer(resultVector[i]), this.stAbbrev[i]);
    }
    return resultMap;
  }

  /**
   * Generate a sorted map of result by semantic type (key) -> score (value).
   * 
   * @param resultvector 
   * @return sorted map of result vector
   */
  public SortedMap mapStiResultBySemType(int[] resultVector)
  {
    // the supplied anonymous comparator sorts the result by score in reverse order.
    SortedMap resultMap = new TreeMap(new Comparator() {
	public int compare(Object o1, Object o2) {
	  int cc = ((String)o1).compareTo((String)o2);
	  return (cc < 0 ? 1 : cc > 0 ? -1 : 0);
	}
      });
    // load scores into Sorted Map with associated semantic type name.
    for (int i = 0; i<STVECTORSIZE; i++) {
      resultMap.put(this.stAbbrev[i], new Integer(resultVector[i]));
    }
    return resultMap;
  }


  public void displayStiResult(int[] resultVector, int topN)
  {
    SortedMap resultMap = mapStiResult(resultVector);
    int i = 0;
    Iterator mapIterator = resultMap.keySet().iterator();
    while (mapIterator.hasNext() && i < topN) {
      Integer score = (Integer)mapIterator.next();
      System.out.println( scoreFormat.format(score.doubleValue()*0.0001) + " " + resultMap.get(score) );
      i++;
    }
  }

  public String pickBestSemType(int[] result, List semTypeList) 
  {
    int topScore = 0;
    String topSemType = null;

    if (logger.isDebugEnabled())
      logger.debug("pickBestSemType:input semantic types = " + semTypeList );

    for (int i = 0; i<result.length; i++) {
      Iterator stypeIterator = semTypeList.iterator();
      while (stypeIterator.hasNext() ) {
        String semType = (String)stypeIterator.next();
        if (semType.equals(this.stAbbrev[i])) {
          if (result[i] > topScore) {
            topScore = result[i];
            topSemType = semType;
          } else if (topSemType == null) {
            topScore = result[i];
            topSemType = semType;
	  }
        }
      }
    }
    return topSemType;
  }

  public final static void main(String[] args)
  {
    if (args.length > 0) {
      // read semtypes
      List semtypes = StringUtils.split(args[0], ",");
      // read query
      StringBuffer query = new StringBuffer();
      for (int i = 1; i < args.length; i++) {
        query.append(args[i]).append(" ");
      }
      // WSDEnvironment.initialize();
      // System.out.println("ServerConfigFile: " + WSDEnvironment.SERVER_CONFIG_FILE);
      SemTypeIndexingMethodTrie stim = new SemTypeIndexingMethodTrie();
      int[] resultVector = stim.calculateStiProfileVector(query.toString());
      stim.displayStiResult(resultVector, 10);
      SortedMap resultMap = stim.mapStiResult(resultVector);
      System.out.println("best semantic type of " + semtypes + " is " + stim.pickBestSemType(resultVector, semtypes));
      WSDEnvironment.shutdown();
    } else {
      System.err.println("usage: java wsd.util.SemanticIndexMethod semtypes query");
      System.err.println("  semtypes are of the form: semtype,semtype,.. (with no spaces)");
      System.exit(1);
    }
  }
}


