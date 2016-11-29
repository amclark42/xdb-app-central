<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:wwp="http://www.wwp.northeastern.edu/ns/textbase"
  xmlns:wf="http://www.wwp.northeastern.edu/ns/functions"
  exclude-result-prefixes="xs xsl wwp wf"
  xpath-default-namespace="http://www.wwp.northeastern.edu/ns/textbase"
  version="2.0">
  
  <!-- This stylesheet creates a version of a WWO text suitable for full-text indexing. -->
  
  <xsl:output indent="yes"/>
  
  
  <!-- FUNCTIONS -->
  
  <xsl:function name="wf:get-first-word" as="xs:string">
    <xsl:param name="text" as="xs:string"/>
    <xsl:variable name="slim-text" select="normalize-space($text)"/>
    <xsl:value-of select="replace($slim-text,'^\s*(\w+[\.,;:?]?)((\s+|[―—]*).*)?$','$1')"/>
  </xsl:function>
  
  <xsl:function name="wf:is-pbGroup-candidate" as="xs:boolean">
    <xsl:param name="node" as="node()"/>
    <xsl:value-of select="exists( $node[  self::mw[@type = ('catch', 'pageNum', 'sig', 'vol')] 
                                       or self::pb 
                                       or self::milestone
                                       or self::text()[normalize-space() eq ''] ] )"/>
  </xsl:function>
  
  <xsl:function name="wf:remove-at-signs" as="xs:string">
    <xsl:param name="text" as="xs:string"/>
    <xsl:value-of select="replace($text,'@\s*','')"/>
  </xsl:function>
  
  
  <!-- TEMPLATES -->
  
  <xsl:template match="/">
    <xsl:variable name="first-pass">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:apply-templates select="$first-pass" mode="unifier"/>
  </xsl:template>
  
  <!-- Normalize 'ſ' to 's' and (temporarily) turn soft hyphens into '@'. Whitespace 
    after a soft hyphen is dropped. -->
  <xsl:template match="text()">
    <xsl:value-of select="replace(translate(.,'ſ­','s@'),'@\s*','@')"/>
  </xsl:template>
  
  <!-- By default when matching elements, copy it and apply templates to its children. -->
  <xsl:template match="*" mode="#default unifier" priority="-40">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="*|text()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Favor <expan> and <corr> within <choice>. -->
  <xsl:template match="choice">
    <xsl:apply-templates mode="choice"/>
  </xsl:template>
  <xsl:template match="abbr | sic" mode="choice"/>
  <xsl:template match="expan | corr" mode="choice">
    <xsl:apply-templates mode="#default"/>
  </xsl:template>
  
  <!-- Remove <hi>s which capture Distinct Initial Capitals. -->
  <xsl:template match="hi [@rend][contains(@rend,'class(#DIC)')]
                     | hi [@rend][contains(@rend,'case(allcaps)')]
                          [preceding-sibling::node()[1][self::hi[@rend][contains(@rend,'class(#DIC)')]]]">
    <xsl:value-of select="text()"/>
  </xsl:template>
  
  <!-- Silently replace <vuji> with its regularized character. -->
  <xsl:template match="vuji">
    <xsl:variable name="text" select="normalize-space(.)"/>
    <xsl:value-of select="if ( $text eq 'VV' ) then 'W'
                     else if ( $text eq 'vv' ) then 'w'
                     else translate($text,'vujiVUJI','uvijUVIJ')"/>
  </xsl:template>
  
  <!-- Replace <lb>s and <cb>s with a single space. -->
  <xsl:template match="lb | cb">
    <xsl:text> </xsl:text>
  </xsl:template>
  
  <!-- Working assumptions:
        * Elements in a "pbGroup" will always share the same parent.
          * This apparently isn't always true in our textbase, but it probably should be?
        * If there are text nodes in between pbGroup elements, they will contain only whitespace.
        * Relevant <mw>s have a @type of "catch", "pageNum", "sig", or "vol".
        * <milestone> must appear immediately after <pb>.
        * Catchwords must appear before <pb>.
        * Other @types of <mw> can appear either before or after <pb>, depending on the text.
        * Each pbGroup must contain, at minimum, one <pb> and one <milestone> (2 members minimum).
        * Each pbGroup may contain one <mw> of each relevant @type (6 members maximum).
        * With intermediate whitespace, the final member of an pbGroup may be 11 positions away from the first, at most.
  -->
  <xsl:template match="mw[@type = ('catch', 'pageNum', 'sig', 'vol')] | pb | milestone">
    <!-- If this is the first in an pbGroup, start pbGrouper mode to collect this 
      element's related siblings. If there are other pbGroup candidates before this 
      one, nothing happens. -->
    <xsl:if test="not(preceding-sibling::*[1][wf:is-pbGroup-candidate(.)])">
      <ab xmlns="http://www.wwp.northeastern.edu/ns/textbase" type="pbGroup">
        <xsl:variable name="my-position" select="position()"/>
        <xsl:if test="count(subsequence(parent::*/(* | text()),1,$my-position)) gt 0">
          <xsl:variable name="groupmates">
            <xsl:variable name="siblings-after" select="subsequence(parent::*/(* | text()),$my-position,14)"/>
            <xsl:variable name="first-nonmatch">
              <xsl:variable name="nonmatches" as="xs:boolean*">
                <xsl:for-each select="$siblings-after">
                  <xsl:variable name="this" select="."/>
                  <xsl:value-of select="not(wf:is-pbGroup-candidate($this))"/>
                </xsl:for-each>
              </xsl:variable>
              <xsl:value-of select="index-of($nonmatches,true())[1]"/>
            </xsl:variable>
            <xsl:variable name="potential-group" select=" if ( $first-nonmatch ne '' ) then 
                                                            subsequence($siblings-after, 1, $first-nonmatch - 1) 
                                                          else $siblings-after"/>
            <xsl:variable name="pattern" select="for $i in $potential-group
                                                 return 
                                                  if ( $i[self::mw] ) then 
                                                    $i/@type
                                                  else $i/local-name()"/>
            <!--<xsl:message>
              <xsl:value-of select="string-join($pattern,'/')"/>
            </xsl:message>-->
            <xsl:copy-of select="$potential-group"/>
          </xsl:variable>
          <!--<xsl:message>
            I am a <xsl:value-of select="local-name()"/>.
            My parent is <xsl:value-of select="parent::*/local-name()"/>.
            My position is <xsl:value-of select="position()"/>.
          </xsl:message>-->
          <xsl:apply-templates select="$groupmates" mode="pbGrouper"/>
        </xsl:if>
      </ab>
    </xsl:if>
  </xsl:template>
  
  
  <!-- MODE: pbGrouper -->
  
  <xsl:template match="text()" mode="pbGrouper"/>
  
  <xsl:template match="mw | pb | milestone" mode="pbGrouper">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <!-- No children are carried through. -->
    </xsl:copy>
  </xsl:template>
  
  
  <!-- MODE: unifier -->
  
  <!-- Remove '@' delimiters from text. If the preceding non-whitespace node ended 
    with an '@', remove the initial word fragment. -->
  <xsl:template match="text()" mode="unifier" priority="-5">
    <xsl:variable name="munged" select="if ( preceding::text()[not(normalize-space(.) eq '')][1][matches(.,'@\s*$')] ) then
                                          substring-after(., wf:get-first-word(.))
                                        else ."/>
    <xsl:value-of select="wf:remove-at-signs($munged)"/>
  </xsl:template>
  
  <!-- Copy whitespace forward. -->
  <xsl:template match="text()[normalize-space(.) eq '']" mode="unifier">
    <xsl:copy/>
  </xsl:template>
  
  <!-- If text has a soft-hyphen delimiter at the end, grab the next part of the 
    word from the next non-whitespace text node. -->
  <xsl:template match="text()[matches(.,'@\s*$')]" mode="unifier" priority="30">
    <xsl:variable name="text-after" select="following::text()[not(normalize-space(.) eq '')][1]"/>
    <xsl:variable name="wordpart-one" select="replace(.,'.*\s+(.+)@\s*$','$1')"/>
    <xsl:variable name="wordpart-two" select="wf:get-first-word($text-after)"/>
    <!--<xsl:variable name="last-word" select="concat($wordpart-one,$wordpart-two)"/>-->
    <xsl:value-of select="wf:remove-at-signs(.)"/>
    <xsl:value-of select="wf:remove-at-signs($wordpart-two)"/>
    <xsl:text> </xsl:text>
  </xsl:template>
  
  <!-- Add a blank line before pbGroups. -->
  <xsl:template match="ab[@type eq 'pbGroup']" mode="unifier">
    <xsl:text>
</xsl:text>
    <xsl:copy-of select="."/>
  </xsl:template>
  
</xsl:stylesheet>