<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:wwp="http://www.wwp.northeastern.edu/ns/textbase"
  xmlns:wf="http://www.wwp.northeastern.edu/ns/functions"
  exclude-result-prefixes="xs xsl wwp wf"
  xpath-default-namespace="http://www.wwp.northeastern.edu/ns/textbase"
  version="2.0">
  
  <xsl:output indent="yes"/>
  
  <xsl:function name="wf:is-pbGroup-candidate" as="xs:boolean">
    <xsl:param name="element" as="node()"/>
    <xsl:value-of select="exists($element [  self::mw[@type = ('catch', 'pageNum', 'sig', 'vol')] 
                                          or self::pb 
                                          or self::milestone
                                          or self::text()[normalize-space() eq ''] ])"/>
  </xsl:function>
  
  <xsl:template match="text()">
    <xsl:value-of select="translate(.,'ſ­','s@')"/>
  </xsl:template>
  
  <xsl:template match="*" priority="-40">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="*|text()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/">
    <xsl:apply-templates/>
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
                          [following-sibling::node()[1][self::hi[@rend][contains(@rend,'case(allcaps)')]]]
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
  
  <!-- Remove <lb>s and <cb>s. -->
  <xsl:template match="lb | cb"/>
  
  <!-- Working assumptions:
        * Elements in a "pbGroup" will always share the same parent.
        * If there are text nodes in between pbGroup elements, they will contain only whitespace.
        * Relevant <mw>s have a @type of "catch", "pageNum", "sig", or "vol".
        * <milestone> must appear immediately after <pb>.
        * Other @types of <mw> can appear either before or after <pb>, depending on the text.
        * Each pbGroup must contain, at minimum, one <pb> and one <milestone> (2 members minimum).
        * Each pbGroup may contain one <mw> of each relevant @type (6 members maximum).
        * With intermediate whitespace, the final member of an pbGroup may be 11 positions away from the first, at most.
  -->
  <xsl:template match="mw[@type = ('catch', 'pageNum', 'sig', 'vol')] | pb | milestone">
    <!-- If this is the first in an pbGroup, start pbGrouper mode to collect this element's related siblings. -->
    <xsl:if test="not(preceding-sibling::*[1][wf:is-pbGroup-candidate(.)])">
      <ab xmlns="http://www.wwp.northeastern.edu/ns/textbase" type="pbGroup">
        <xsl:variable name="groupmates">
          <xsl:variable name="my-position" select="position()"/>
          <xsl:variable name="siblings-after" select="subsequence(parent::*/(* | text()),$my-position,11)"/>
          <xsl:variable name="first-nonmatch" select="index-of($siblings-after, $siblings-after[not(wf:is-pbGroup-candidate(.))][1])[1]"/>
          <xsl:variable name="potential-group" select=" if ( exists($first-nonmatch) ) then 
                                                          subsequence($siblings-after, 1, $first-nonmatch - 1) 
                                                        else $siblings-after"/>
          <xsl:variable name="pattern" select="for $i in $potential-group
                                               return 
                                                if ( $i[self::mw] ) then 
                                                  $i/@type
                                                else $i/local-name()"/>
          <xsl:message><xsl:value-of select="string-join($pattern,'/')"/></xsl:message>
          <xsl:copy-of select="$potential-group"/>
        </xsl:variable>
        <!--<xsl:variable name="last" 
          select="following-sibling::*[wf:is-pbGroup-candidate(.)]
                                      [preceding::text()[1][normalize-space(.) eq '']]
                                      [not(following-sibling::*[1][wf:is-pbGroup-candidate(.)])][1]"/>-->
        <!--<xsl:message>
          I am a <xsl:value-of select="local-name()"/>.
          My parent is <xsl:value-of select="parent::*/local-name()"/>.
          My position is <xsl:value-of select="position()"/>.
        </xsl:message>-->
        <xsl:apply-templates select="$groupmates" mode="pbGrouper"/>
      </ab>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="text()" mode="pbGrouper"/>
  
  <xsl:template match="mw | pb | milestone" mode="pbGrouper">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <!--<xsl:template match="mw[@type eq 'catch']" mode="#all"/>-->
  
</xsl:stylesheet>