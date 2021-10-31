<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xhl="https://apply-templates.com/templates/syntaxhighlighter"
               version="1.0">

    <xsl:output method="xml" encoding="UTF-8"/>

    <!--
        This is a syntax highlighter, intended for use with the website apply-templates.com
    -->


    <xsl:template match="/">
        <xsl:call-template name="xhl"/>
    </xsl:template>

    <xsl:template name="xhl">
        <xhl:hl>
            <xsl:call-template name="XMLHighlighter">
                <xsl:with-param name="code" select="/"/>
            </xsl:call-template>
        </xhl:hl>
    </xsl:template>

    <xsl:template name="XMLHighlighter">
        <xsl:param name="code"/>
        <xsl:choose>
            <xsl:when test="1 =2 "/>
            <xsl:when test="substring($code,1,2) = '&lt;?'">
                <xhl:PITag>
                    <xsl:text>&lt;?</xsl:text>
                </xhl:PITag>
                <xhl:PIName>
                    <xsl:value-of select="substring(substring-before($code,' '),3,string-length(substring-before($code,' '))-2)"/>
                </xhl:PIName>
                <xhl:PIString>
                    <xsl:value-of select="substring-after(substring-before($code,'?&gt;'),' ')"/>
                </xhl:PIString> 
                <xhl:PITag>
                    <xsl:text>?&gt;</xsl:text>
                </xhl:PITag>
                <xsl:call-template name="XMLHighlighter">
                    <xsl:with-param name="code" select="substring-after($code,'?&gt;')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="substring($code,1,1) = '&lt;'">
                <xsl:variable name="rcode">
                    <xsl:choose>
                        <xsl:when test="substring($code,1,2) = '&lt;/'">
                            <xsl:value-of select="substring($code,3,string-length($code)-2)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="substring($code,2,string-length($code)-1)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="substring($code,1,2) = '&lt;/'">
                        <xhl:elementbracket>&lt;/</xhl:elementbracket>
                    </xsl:when>
                    <xsl:otherwise>
                        <xhl:elementbracket>&lt;</xhl:elementbracket>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="contains(substring-before($rcode,'&gt;'),' ')">
                        <xhl:elementname>
                            <xsl:value-of select="substring-before($rcode,' ')"/>
                        </xhl:elementname>
                        <xsl:call-template name="XHLAttributes">
                            <xsl:with-param name="attrs" select="substring-before(substring-after($rcode,' '),'&gt;')"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xhl:elementname>
                            <xsl:value-of select="substring-before($rcode,'&gt;')"/>
                        </xhl:elementname>
                    </xsl:otherwise>
                </xsl:choose>
                <!--
                <xsl:choose>
                    <xsl:when test="substring(substring-before($code,'&gt;'), string-length(substring-before($code,'&gt;')), 1) ='/'">
                        <xsl:call-template name="xhlAttributes"/>
                        <xhl:elementbracket>/</xhl:elementbracket>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="xhlAttributes"/>
                    </xsl:otherwise>
                </xsl:choose>
                -->
                <xhl:elementbracket>&gt;</xhl:elementbracket>
                <xsl:call-template name="XMLHighlighter">
                    <xsl:with-param name="code" select="substring-after($rcode,'&gt;')"/>
                </xsl:call-template>
            </xsl:when>

            <!-- Gotta Stop stack overflowing! -->
            <xsl:when test="string-length($code) = 0"/>
            <xsl:otherwise>
                <xsl:value-of select="substring($code,1,1)"/>
                <xsl:call-template name="XMLHighlighter">
                    <xsl:with-param name="code" select="substring-after($code,substring($code,1,1))"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="XHLAttributes">
        <xsl:param name="attrs"/>
        <xsl:if test="contains($attrs,'=')">
            <xhl:space><xsl:text> </xsl:text></xhl:space>
            <xhl:attrname>
                <xsl:value-of select="normalize-space(substring-before($attrs,'='))"/>
            </xhl:attrname>
            <xhl:equals>=</xhl:equals>
            <xhl:quote>&quot;</xhl:quote>
            <xhl:attrvalue>
                <xsl:value-of select="substring-before(substring-after($attrs,'=&quot;'),'&quot;')"/>
            </xhl:attrvalue>
            <xhl:quote>&quot;</xhl:quote>
            <xsl:call-template name="XHLAttributes">
                <xsl:with-param name="attrs" select="substring-after(substring-after($attrs,'=&quot;'),'&quot;')"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

</xsl:transform>