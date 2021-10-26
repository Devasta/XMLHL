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

            <xsl:when test="substring($code,1,1) = '&lt;'">
                <xhl:elementbracket>&lt;</xhl:elementbracket>
                <xsl:choose>
                    <xsl:when test="contains(substring-before(substring($code,2,string-length($code)-1),'&gt;'),' ')">
                        <xhl:elementname>
                            <xsl:value-of select="substring-before(substring($code,2,string-length($code)-1),' ')"/>
                        </xhl:elementname>
                        <xhl:attributes>
                            <xsl:value-of select="substring-before(substring-after(substring($code,2,string-length($code)-1),' '),'&gt;')"/>
                        </xhl:attributes>
                    </xsl:when>
                    <xsl:otherwise>
                        <xhl:elementname>
                            <xsl:value-of select="substring-before(substring($code,2,string-length($code)-1),'&gt;')"/>
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
                    <xsl:with-param name="code" select="substring-after($code,'&gt;')"/>
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

    <xsl:template name="xhlAttributes">

    </xsl:template>


</xsl:transform>