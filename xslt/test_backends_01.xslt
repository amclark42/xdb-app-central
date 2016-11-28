<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="xs xd"
  xpath-default-namespace="http://www.wwp.northeastern.edu/ns/textbase"
  xmlns="http://www.w3.org/1999/xhtml"
  version="2.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Nov 28, 2016</xd:p>
      <xd:p><xd:b>Author:</xd:b> syd</xd:p>
      <xd:p></xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:output method="xhtml"/>
  
  <xsl:template match="/">
    <html>
      <head>
        <title><xsl:call-template name="get-title"/></title>
        <style type="text/css">
          <xsl:call-template name="get-renditions"/>
          body { background-color: #222; }
          div.outerWrapper { background-color: #EEE; margin: 2em; }
          div.outerWrapper > h1 { text-align: center; padding: 1ex; }
          div.metadata4usr {
            margin: 1ex 5em 5em 5em;
            padding: 1ex 3ex 1ex 3ex;
            display: block;
            background-color: #DEF;
            border: thick ridge blue;
            }
          span.temporal:before { color: #AAA; content: "{"; }
          span.temporal { color: #AAA; }
          span.temporal:after { color: #AAA; content: "}"; }
          span[class|=mw] { display: none; }
          span.pb, span.milestone-sig { display: block; color: red; }
          div.TOC {
            display: block;
            position: absolute;
            right: 6em;
            font-style: oblique;
            font-weight: bold;
            color: blue;
            }
          div.text {
            display: block;
            margin: 1em 2em 2em 2em;
            padding: 1ex 3ex 1ex 3ex;
            }
          span.del {
            text-decoration: line-through;
            }
          span.add {
            vertical-align: super;
            }
        </style>
        <script src=""/>
      </head>
      <body>
        <div class="outerWrapper">
          <xsl:apply-templates select="TEI/teiHeader"/>
          <xsl:call-template name="get-toc"/>
          <xsl:apply-templates select="TEI/text"/>
        </div>
      </body>
    </html>
  </xsl:template>
  
  <!-- main metadata-for-user routine -->
  <xsl:template match="TEI/teiHeader">
    <h1><xsl:call-template name="get-title"/></h1>
    <div class="metadata4usr">
      <dl>
        <dt>author</dt>
        <dd><xsl:call-template name="get-author"/></dd>
        <dt>date</dt>
        <dd><xsl:call-template name="get-orig-date"/></dd>
        <dt>WWP #</dt>
        <dd><xsl:value-of select="fileDesc/publicationStmt/idno[@type eq 'WWP']"/></dd>
        <dt>categorization</dt>
        <dd>
          <!-- should chase the pointer, rather than just use it -->
          <xsl:value-of select="
            translate( substring-after( profileDesc/textClass/catRef[@type eq 'main']/@target,'#G.'),'.',' ')"/>
        </dd>
      </dl>
    </div>
  </xsl:template>
  
  <xsl:template name="get-toc">
    <xsl:if test="count( /TEI/text/div ) gt 6
      or
      /TEI/teiHeader//extent/measure[ @unit eq 'page' and xs:integer(@quantity) gt 12 ]
      or
      string-length(/TEI/text) gt 67532">
      <div class="TOC">
        generate a TOC here
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="text">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- main processing yanked from WWO/style/dynaXML/docFormatter/wwo/component.xsl -->

  <xsl:template match="hyperDiv | div[@type='notes']/note" name="homicide" priority="1"/>
  
  <xsl:template name="suicide" match="vuji|regMe">
    <xsl:apply-templates select="node()"/>
  </xsl:template>
  
  <xsl:template name="infanticide">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="getID" match="*">
    <xsl:value-of select="if (@xml:id) then @xml:id else generate-id(.)"/>
  </xsl:template>
  
  <xsl:template name="anchorMe">
    <xsl:variable name="myID" select="if (@xml:id) then @xml:id else generate-id(.)"/>
    <xsl:attribute name="id" select="$myID"/>
  </xsl:template>
  
  <xsl:template match="*" priority="-5">
    <span class="debug">INTERNAL ERROR. Please report to wwp@neu.edu that <xsl:value-of
      select="local-name(.)"/> is unmatched.</span>
    <xsl:message>INTERNAL ERROR. Please report to wwp@neu.edu that <xsl:value-of
      select="local-name(.)"/> in <xsl:value-of select="/TEI/teiHeader/fileDesc/publicationStmt/idno[@type eq 'WWP']"/> is unmatched.</xsl:message>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@*" mode="#default"/>
  
  <xsl:template match="@style" mode="#all">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template match="@*" mode="spanAttr">
    <xsl:choose>
      <xsl:when test="local-name(.) = ('quotes','slant','pre','post','indent','break','case','braced','align','bestow','first-indent')"/>
      <xsl:otherwise>
        <span class="{concat('attr-',name(.))}"><xsl:value-of select="."/></span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ====================================================================== -->
  <!-- lists of elements that, by default, become  each of <div>, <p>, and     -->
  <!-- <span> in the XHTML output                                             -->
  <!-- ====================================================================== -->
  <xsl:variable name="toHTMLdiv" select="(
    'advertisement',
    'argument',
    'back',
    'body',
    'castGroup',
    'castList',
    'closer',
    'div',
    'docAuthor',
    'docAuthorization',
    'docEdition',
    'epigraph',
    'figDesc',
    'figure',
    'floatingText',
    'front',
    'group',
    'imprimatur',
    'lg',
    'listBibl',
    'opener',
    'set',
    'sp',
    'spGrp',
    'text',
    'titleBlock'
    )"/>
  <xsl:variable name="toHTMLp" select="(
    'ab',
    'byline',
    'castItem',
    'dateline',
    'docImprint',
    'docSale',
    'elision',
    'imprint',
    'label',
    'monogr',
    'p',
    'postscript',
    'respLine',
    'salute',
    'series',
    'signed',
    'speaker',
    'titlePart',
    'trailer'
    )"/>
  <xsl:variable name="toHTMLspan" select="(
    'abbr',
    'addSpan',
    'actor',
    'add',
    'anchor',
    'author',
    'bibl',
    'biblScope',
    'choice',
    'corr',
    'del',
    'delSpan',
    'distinct',
    'docRole',
    'edition',
    'editor',
    'emph',
    'expan',
    'foreign',
    'forename',
    'g',
    'gloss',
    'hi',
    'lem',
    'mcr',
    'measure',
    'mentioned',
    'mw',
    'name',
    'num',
    'note',
    'orgName',
    'orig',
    'persName',
    'placeName',
    'pubPlace',
    'publisher',
    'rdg',
    'ref', (: obviously doesn't belong here :)
    'q',
    'quote',
    'reg',
    'role',
    'roleDesc',
    'rs',
    'said',
    'seg',
    'sic',
    'soCalled',
    'stage',
    'supplied',
    'surname',
    'term',
    'title',
    'unclear'
    )"/>
  
  <!-- ====================================================================== -->
  <!-- generic <html:div>s                                                    -->
  <!-- ====================================================================== -->

  <xsl:template match="*[local-name(.)=$toHTMLdiv][not( ancestor::*[local-name(.)=$toHTMLp] | ancestor::*[local-name(.)=$toHTMLspan] )]">
    <!-- if an element that has only element content has no -->
    <!-- children, don't even bother -->
    <xsl:if test="not( self::lg|self::div ) or child::* ">
      <xsl:variable name="subtype" select="if (@subtype) then concat('-',@subtype) else ''"/>
      <xsl:variable name="type" select="if (@type) then concat('-',@type,$subtype) else ''"/>
      <xsl:variable name="class" select="concat( local-name(.), $type, $subtype )"/>
      <div class="{$class}">
        <xsl:call-template name="anchorMe"/>
        <xsl:apply-templates select="@*|node()"/>
      </div>
    </xsl:if>
  </xsl:template>

  <!-- ====================================================================== -->
  <!-- generic <html:p>s                                                      -->
  <!-- ====================================================================== -->

  <xsl:template match="*[local-name(.)=$toHTMLp][not( ancestor::*[local-name(.)=$toHTMLp] | ancestor::*[local-name(.)=$toHTMLspan] )]">
    <xsl:variable name="subtype" select="if (@subtype) then concat('-',@subtype) else ''"/>
    <xsl:variable name="type" select="if (@type) then concat('-',@type,$subtype) else ''"/>
    <xsl:variable name="quotes" select="if (@quotes) then concat(' ',@quotes) else ''"/>
    <xsl:variable name="class" select="concat( local-name(.), $type, $subtype, $quotes )"/>
    <!-- first handle content up to and including the last <list> inside me -->
    <xsl:for-each select="list">
      <!-- remember the <list> before me (now "me" = current <list>) -->
      <xsl:variable name="before-me" select="preceding-sibling::node()[self::list][1]"/>
      <!-- 
                                ** The content we want is everthing between previous
                                ** <list> and me (the current <list>).
                                ** However, don't ask me exactly how this predicate works. While
                                ** I understand each little piece, I think, I don't get the big
                                ** picture, and I don't understand the detail of why the equality
                                ** test could ever fail. It is modified from the incomparable Jeni
                                ** Tennison's post to XSL-List of 2001-01-19T15:49Z "How to
                                ** transform <BR> to </P><P>"
                                ** (http://xslt.com/html/xsl-list/2001-01/msg00927.xhtml),
                                ** which I found via Dave Pawson's awesomely helpful FAQ at
                                ** http://www.dpawson.co.uk/xsl/index.xhtml
                        -->
      <xsl:variable name="content"
        select="preceding-sibling::node()
        [not($before-me) or
        generate-id(preceding-sibling::node()[self::list][1]) =
        generate-id($before-me)]" />
      <!-- if there is any content ... -->
      <xsl:if test="$content">
        <!-- ... put it out in a <p> before we ... -->
        <p class="{$class}"><xsl:apply-templates select="@*|$content"/></p>
      </xsl:if>
      <!-- ... put current node (and its children) into the output tree. -->
      <xsl:apply-templates select="."/>
    </xsl:for-each>
    <!-- Note that if there is no <eg> or <list>, the above template did nothing. -->
    <!-- So now we still need to handle the content from the last <eg> or <list> -->
    <!-- (exclusive of it) to the end-of-me, and all my content if there was no -->
    <!-- <eg> or <list>. So the first step is to select all such nodes and tuck 'em -->
    <!-- in a variable. So this XPath selects all nodes that are not <eg> or <list> -->
    <!-- and do not have any <eg> or <list> following. Thus, if there is neither -->
    <!-- an <eg> nor a <list>, it selects all my child nodes. -->
    <xsl:variable name="end-content"
      select="node()[not(self::list) and not(following-sibling::list)]"/>
    <xsl:if test="$end-content">
      <p class="{$class}">
        <xsl:apply-templates select="@*"/>
        <!-- for reasons I cannot explain applying templates to $end-content gen- -->
        <!-- erates output in non-document order -->
        <xsl:apply-templates select="node()[
          not( self::list )
          and
          not( following-sibling::list )
          ]"/>
      </p>
    </xsl:if>
  </xsl:template>

  <!-- ====================================================================== -->
  <!-- generic <html:span>s                                                   -->
  <!-- ====================================================================== -->

  <xsl:template match="*[local-name(.)=$toHTMLspan]
                      |*[local-name(.)=($toHTMLdiv,$toHTMLp)][ ancestor::*[local-name(.)=$toHTMLp] | ancestor::*[local-name(.)=$toHTMLspan] ]">
    <xsl:variable name="level" select="if (@level) then concat('-',@level) else ''"/>
    <xsl:variable name="subtype" select="if (@subtype) then concat('-',@subtype) else ''"/>
    <xsl:variable name="type" select="if (@type) then concat('-',@type,$subtype) else ''"/>
    <xsl:variable name="slant">
      <xsl:choose>
        <!-- note that blank before 2-letter code is important, as it is not inserted -->
        <!-- in the definition of $class, below -->
        <xsl:when test="@slant eq 'italic'"> it</xsl:when>
        <xsl:when test="@slant eq 'upright'"> ro</xsl:when>
        <xsl:when test="self::choice">
          <!-- special cases for MME ... -->
          <xsl:if test="ancestor::text[@type='manuscript']">
            <!-- ... inside a manuscript -->
            <xsl:text>-ms</xsl:text>
          </xsl:if>
          <xsl:if test="@n eq 'mult'">
            <!-- ... 3+ children ... -->
            <xsl:text>-mult</xsl:text>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="quotes" select="if (@quotes) then concat(' ',@quotes) else ''"/>
    <xsl:variable name="sameAs" select="if (self::seg/@sameAs) then ' sameAs' else ''"/>
    <xsl:variable name="class" select="concat( local-name(.), $type, $level, $slant, $quotes, $sameAs )"/>
      <!--<xsl:if test="self::note | self::bibl">
      <xsl:message>DEBUG: processing <xsl:value-of select="local-name(.)"
      /> #<xsl:value-of select="count( preceding::*[local-name(.) = local-name( current() )] )+1"
      />, default mode, output class=<xsl:value-of select="$class"/></xsl:message>
    </xsl:if> -->
    <xsl:if test="not( self::note[@type = ('annotation','textual') ] )">
      <span class="{$class}">
        <xsl:apply-templates select="@*|node()"/>
      </span>
    </xsl:if>
  </xsl:template>

  <!-- ====================================================================== -->
  <!-- Heads                                                                  -->
  <!-- ====================================================================== -->

  <xsl:template match="head">
    <xsl:variable name="depth"
      select="count( ancestor::figure|ancestor::argument|ancestor::castGroup|ancestor::listBibl|ancestor::listEvent|ancestor::set|ancestor::note|ancestor::postscript|ancestor::body|ancestor::castList|ancestor::div|ancestor::group|ancestor::lg|ancestor::list|ancestor::performance|ancestor::back|ancestor::front )"/>
    <xsl:variable name="outGI">
      <xsl:choose>
        <xsl:when test="ancestor::*[local-name(.)=$toHTMLp] or ancestor::*[local-name(.)=$toHTMLspan]">
          <xsl:text>span</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>p</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$outGI}">
      <xsl:variable name="quotes" select="if (@quotes) then concat(' ',@quotes) else ''"/>
      <xsl:attribute name="class" select="concat('head-', format-number( $depth,'00'), $quotes )"/>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:element>
  </xsl:template>

  <!-- ====================================================================== -->
  <!-- Verse                                                                  -->
  <!-- ====================================================================== -->

  <xsl:template match="l">
    <xsl:variable name="gi">
      <xsl:choose>
        <xsl:when test="ancestor::*[local-name(.) = ( $toHTMLp, $toHTMLspan )]  or  @break eq 'no'">span</xsl:when>
        <xsl:otherwise>p</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$gi}">
      <xsl:variable name="quotes" select="if (@quotes) then concat(' ',@quotes) else ''"/>
      <xsl:attribute name="class" select="concat(
        if (@break='no') then 'l-inline' else 'l',
        $quotes
        )"/>
      <xsl:apply-templates select="@*|node()"/>
      <!-- span class="lng"><xsl:value-of select="lng"/></span -->
      <span class="lnr"><xsl:value-of select="lnr"/></span>
      <!-- span class="lnl"><xsl:value-of select="lnl"/></span-->
    </xsl:element>
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Lists                                                                  -->
  <!-- ====================================================================== -->

  <xsl:template match="list">
    <xsl:apply-templates select="./head"/>
    <xsl:choose>
      <xsl:when test="label">
        <dl>
          <xsl:if test="@type">
            <xsl:attribute name="class" select="@type"/>
          </xsl:if>
          <xsl:apply-templates select="@*[name()!='type']"/>
          <xsl:apply-templates select="node()[not(self::head)]" mode="gloss"/>
        </dl>
      </xsl:when>
      <xsl:otherwise>
        <ul>
          <xsl:if test="@type">
            <xsl:attribute name="class" select="@type"/>
          </xsl:if>
          <xsl:apply-templates select="@*[name()!='type']"/>
          <xsl:apply-templates select="node()[not(self::head)]"/>
        </ul>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="item">
    <li>
      <xsl:apply-templates select="@*|node()"/>
    </li>
  </xsl:template>
  <xsl:template match="label" mode="gloss">
    <dt>
      <xsl:apply-templates select="@*|node()"/>
    </dt>
  </xsl:template>
  <xsl:template match="item" mode="gloss">
    <dd>
      <xsl:apply-templates select="@*|node()"/>
    </dd>
  </xsl:template>
  
  <xsl:template match="text()">
    <!-- do three things with text nodes: -->
    <!-- 2) nuke whitespace-only children of <choice> -->
    <!-- 2) convert ' to ’ (unless in <code> or looks like attr value) -->
    <!-- 3) nuke initial punctuation mark iff right after a list -->
    <xsl:variable name="step1">
      <xsl:choose>
        <xsl:when test="parent::choice  and  normalize-space(.) eq ''"/>
        <xsl:when test="ancestor::code">
          <xsl:value-of select="."/>
        </xsl:when>
        <xsl:otherwise>
          <!-- set up some values we'll use in a moment -->
          <xsl:variable name="apos" select='"&apos;"'/> <!-- i.e., ' = U+0027 -->
          <xsl:variable name="litPat">=\s*"[^"]*'[^"]*"</xsl:variable>
          <xsl:variable name="litaPat">(=\s*)’([^’]+)’</xsl:variable>
          <xsl:variable name="litaRep">$1'$2'</xsl:variable>
          <!-- as long as ' is not inside an attr value, change to ’ -->
          <xsl:variable name="phase1">
            <xsl:analyze-string select="." regex="$litPat">
              <xsl:matching-substring><xsl:value-of select="."/></xsl:matching-substring>
              <xsl:non-matching-substring><xsl:value-of select="translate(.,$apos,'&#x2019;')"/></xsl:non-matching-substring>
            </xsl:analyze-string>
          </xsl:variable>
          <!-- then revert those that are being used as LITA attribute value -->
          <!-- delimiters, and return that string  -->
          <xsl:value-of select="replace($phase1,$litaPat,$litaRep)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="step2">
      <xsl:choose>
        <xsl:when test="preceding-sibling::node()[1][self::list]">
          <!-- Special-case a sentence-ending punctuation mark that immediately -->
          <!-- follows a <list>. For now just nuke the punctuation. -->
          <xsl:value-of select="replace( $step1,'^[&#x20;&#x09;&#x0D;&#x0A;]*[.?!;:]+','')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$step1"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$step2"/>
  </xsl:template>

  <!-- ====================================================================== -->
  <!-- Notes                                                                  -->
  <!-- ====================================================================== -->
  
  <xsl:template match="anchor[@type='generated']" priority="1.0">
    <!-- first, generate a version of myself (so the @quotes information remains in correct spot) -->
    <span>
      <xsl:variable name="subtype" select="if (@subtype) then concat('-',@subtype) else ''"/>
      <xsl:variable name="type" select="if (@type) then concat('-',@type,$subtype) else ''"/>
      <xsl:variable name="quotes" select="if (@quotes) then concat(' ',@quotes) else ''"/>
      <xsl:variable name="class" select="concat( local-name(.), $type, $quotes )"/>
      <xsl:attribute name="class" select="$class"/>
    </span>
    <!-- then put the note that points to this <anchor> to right here -->
    <xsl:variable name="href2me" select="concat('#',@xml:id)"/>
    <span class="popout">
      <xsl:apply-templates select="//note[ tokenize(@target,' ') = $href2me ]" mode="insert-note"/>
    </span>
    <!--<xsl:apply-templates select="key('notes-by-target', @xml:id )" mode="insert-note"/>-->
  </xsl:template>
  <xsl:template match="note" mode="insert-note">
    <xsl:variable name="class" select="concat('note', if (@type) then concat('-', @type) else '' )"/>
    <xsl:variable name="ms" select="if (ancestor::text[@type='manuscript']) then ' ms' else ''"/>
    <span class="{concat($class,$ms)}">
      <xsl:apply-templates select="@*|node()"/>
      <!-- 
        <xsl:apply-templates select="@*" mode="spanAttr"/>
        <span class="noteContent-string"><xsl:value-of select="normalize-space(.)"/></span>
        <span class="noteContent"><xsl:apply-templates select="node()"/></span>
      -->
    </span>
  </xsl:template>
  <xsl:template match="note[@type eq 'headnote']" priority="2">
    <span class="note-headnote">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  
  <xsl:template name="popupContent">
    <xsl:param name="target" required="yes"/>
    <!--<xsl:param name="class"></xsl:param>-->
    <!--<xsl:variable name="class" select="concat('note', if (@type) then concat('-', @type) else '' )"/>-->
    <xsl:variable name="class" select="concat('note', if (@type) then concat('-', @type) else '' )"/>
    <xsl:variable name="ms" select="if (ancestor::text[@type='manuscript']) then ' ms' else ''"/>
    <span class="{concat($class,$ms)}">
      <xsl:apply-templates select="//*[@xml:id=substring(@target,2)]"/>
    </span>
  </xsl:template>
  
  <xsl:template name="popupDiv">
    <div class="popup-group">
      <xsl:for-each select="//note | //ref[@target]">
        <xsl:call-template name="popupContent">
          <xsl:with-param name="target"></xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </div>
  </xsl:template>
  
  <!-- ====================================================================== -->
  <!-- Other Text Blocks                                                      -->
  <!-- ====================================================================== -->

  <xsl:template match="date|docDate|time">
    <span class="{local-name(.)}">
      <!-- I just looked: these are the attrs that exist other than -->
      <!-- those for temporal normalizatoin -->
      <xsl:apply-templates select="@rend|@xml:id|@corresp|@calendar|@next|@prev|@xml:lang"/>
      <xsl:call-template name="temporalNormalization"/>
      <xsl:apply-templates select="node()"/>
    </span>
  </xsl:template>
  
  <xsl:template match="gap">
    <span class="{concat('gap', if (@desc) then concat('-',@desc) else '', if (@ed) then concat('-',@ed) else '')}">
      <xsl:apply-templates select="@xml:id"/>
      <xsl:apply-templates select="@* except ( @xml:id, @desc, @ed )" mode="spanAttr"/>
    </span>
  </xsl:template>

  <!-- ====================================================================== -->
  <!-- Formatting                                                             -->
  <!-- ====================================================================== -->

  <xsl:template match="lb">
    <br/>
  </xsl:template>
  
  <xsl:template match="subst">
    <xsl:apply-templates select="del"/>
    <xsl:apply-templates select="add"/>
  </xsl:template>

  <xsl:template match="app">
    <xsl:apply-templates select="lem"/>
    <xsl:apply-templates select="rdg"/>
  </xsl:template>
  

  <!-- ====================================================================== -->
  <!-- Milestones                                                             -->
  <!-- ====================================================================== -->

  <xsl:template match="pb">
    <!-- xsl:when test="not(following-sibling::*)"/ -->
    <span>
      <xsl:attribute name="class" select="if (@ed) then concat('pb-',@ed) else 'pb'"/>
      <xsl:value-of select="@n"/>
      <!-- If I have a child anchor for purposes of a footnote anchor, spit it out, too -->
      <xsl:apply-templates select="anchor[@type='generated']"/>
    </span>
  </xsl:template>

  <xsl:template match="milestone">
    <!-- all of our <milestone>s are unit=sig -->
    <span class="{concat( local-name(.), '-', @unit, if ( @slant eq 'italic' ) then ' it' else '' )}">
      <xsl:value-of select="@n"/>
    </span>
  </xsl:template>


  <!-- other subroutines, as it were -->
  <xsl:template name="get-title">
    <xsl:choose>
      <xsl:when test="count( /TEI/teiHeader/fileDesc/titleStmt/title[@type='main'] ) = 1">
        <xsl:variable name="titlePlus"
          select="normalize-space(/TEI/teiHeader/fileDesc/titleStmt/title[@type='main'])"/>
        <xsl:analyze-string select="$titlePlus"
          regex="^(.*), [0-9]{{4}}(-([0-9][0-9])?[0-9][0-9])?( \(published [0-9]{{4}}\))?$">
          <xsl:matching-substring>
            <xsl:value-of select="regex-group(1)"/>
          </xsl:matching-substring>
          <xsl:non-matching-substring>
            <xsl:message>WARNING: <xsl:value-of select="$titlePlus"/> did not match title regex</xsl:message>
            <xsl:value-of select="$titlePlus"/>
          </xsl:non-matching-substring>
        </xsl:analyze-string>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>WARNING: either 0 or > 1 main titles</xsl:message>
        <xsl:value-of select="string-join( /TEI/teiHeader/fileDesc/titleStmt/title, ' ')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="get-renditions">
    <!-- do something clever with <tagUsage> here -->
  </xsl:template>

  <xsl:template name="get-author">
    <xsl:variable name="authorOne" select="(
      //fileDesc/titleStmt/author[1]/persName[@type='hack4XTF'],
      //fileDesc/titleStmt/author[1],
      //titlePage/docAuthor[1],
      'unknown'
      )[1]"/>
    <xsl:value-of select="$authorOne"/>
    <div class="author-pop-up">
      <p>metadata about author extracted from personography goes here</p>
    </div>
  </xsl:template>
  
  <xsl:template name="get-orig-date">
    <!-- we take only 1st <imprint>, as liddiard.theodore has 2 -->
    <!-- we take only <sourceDesc> that does not have default=false, as there are some -->
    <!-- of those, and we don't want 'em (at least not as we currently use 'em) -->
    <xsl:choose>
      <xsl:when test="/TEI/teiHeader/fileDesc/sourceDesc[not( @default='false' )]/biblStruct/monogr/imprint[1]/date/@when">
        <xsl:value-of select="//fileDesc/sourceDesc[not( @default='false' )]/biblStruct/monogr/imprint[1]/date/@when"/>
      </xsl:when>
      <xsl:when test="/TEI/teiHeader/fileDesc/sourceDesc[not( @default='false' )]/biblStruct/monogr/imprint[1]/date[@from and @to]">
        <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc[not( @default='false' )]/biblStruct/monogr/imprint[1]/date/@from"/>
        <xsl:text>&#x2013;</xsl:text>
        <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc[not( @default='false' )]/biblStruct/monogr/imprint[1]/date/@to"/>
      </xsl:when>
      <!-- manuscripts are a bit different: -->
      <xsl:when test="/TEI/teiHeader/fileDesc/sourceDesc[not( @default='false' )]/msDesc[not(@xml:id=('gt','rwe'))]//history/origin/origDate[@when]">
        <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc[not( @default='false' )]/msDesc[not(@xml:id=('gt','rwe'))]//history/origin/origDate/@when"/>
      </xsl:when>
      <xsl:when test="/TEI/teiHeader/fileDesc/sourceDesc[not( @default='false' )]/msDesc[not(@xml:id=('gt','rwe'))]//history/origin/origDate[@from and @to]">
        <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc[not( @default='false' )]/msDesc[not(@xml:id=('gt','rwe'))]//history/origin/origDate/@from"/>
        <xsl:text>&#x2013;</xsl:text>
        <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc[not( @default='false' )]/msDesc[not(@xml:id=('gt','rwe'))]//history/origin/origDate/@to"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>ERROR: unable to determine date of publication of source</xsl:message>
        0000
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="temporalNormalization">
    <span class="{concat( 'temporal', if ( @slant eq 'italic' ) then ' it' else '' )}">
      <xsl:choose>
        <xsl:when test="@when or @when-iso">
          <!-- we never have both -->
          <xsl:value-of select="@when"/>
          <xsl:value-of select="@when-iso"/>
        </xsl:when>
        <xsl:when test="@from and @to">
          <xsl:value-of select="concat( @from, '&#x2013;', @to )"/>
        </xsl:when>
        <xsl:when test="@notBefore and @notAfter">
          <xsl:value-of select="concat( @notBefore, ' &lt; ')"/>
          <i>x</i>
          <xsl:value-of select="concat( ' &lt; ', @notAfter )"/>
        </xsl:when>
      </xsl:choose>
    </span>
  </xsl:template>
  
</xsl:stylesheet>