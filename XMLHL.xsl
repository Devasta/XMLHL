<?xml version="1.0" encoding="UTF-8" ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xhl="https://apply-templates.com/XMLHL"
               xmlns:xh="http://www.w3.org/1999/xhtml"
               version="1.0">

    <xsl:output method="xml" encoding="UTF-8" indent="no"/>

    <!--
        This is a syntax highlighter, intended for use with the website apply-templates.com
    -->



    <xsl:template match="xh:code">
        <xhl:hl>
            <xsl:call-template name="XMLHighlighter">
                <xsl:with-param name="code" select="."/>
            </xsl:call-template>
        </xhl:hl>
    </xsl:template>

    <xsl:template name="XMLHighlighter">
        <xsl:param name="code"/>
        <xsl:choose>
            <!-- Gotta Stop stack overflowing! -->
            <xsl:when test="string-length($code) = 0"/>

            <!-- Comments -->
            <xsl:when test="substring($code,1,4) = '&lt;!--'">
                <xhl:commentbracket>
                    <xsl:text>&lt;!-- </xsl:text>
                </xhl:commentbracket>
                <xhl:commenttext>
                    <xsl:value-of select="substring(substring-before($code,'--&gt;'),5,string-length(substring-before($code,'--&gt;'))-3)"/>
                </xhl:commenttext>
                <xhl:commentbracket>
                    <xsl:text>--&gt;</xsl:text>
                </xhl:commentbracket>
                <xsl:call-template name="XMLHighlighter">
                    <xsl:with-param name="code" select="substring-after($code,'--&gt;')"/>
                </xsl:call-template>
            </xsl:when>
            <!-- Processing Instructions -->
            <xsl:when test="substring($code,1,2) = '&lt;?'">
                <xhl:PIBracket>
                    <xsl:text>&lt;?</xsl:text>
                </xhl:PIBracket>
                <xhl:PIName>
                    <xsl:value-of select="substring(substring-before($code,' '),3,string-length(substring-before($code,' '))-2)"/>
                </xhl:PIName>
                <xhl:space><xsl:text> </xsl:text></xhl:space>
                <xhl:PIString>
                    <xsl:value-of select="substring-after(substring-before($code,'?&gt;'),' ')"/>
                </xhl:PIString>
                <xhl:PIBracket>
                    <xsl:text>?&gt;</xsl:text>
                </xhl:PIBracket>
                <xsl:call-template name="XMLHighlighter">
                    <xsl:with-param name="code" select="substring-after($code,'?&gt;')"/>
                </xsl:call-template>
            </xsl:when>
            <!-- Element -->
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
                        <xhl:elementbracket><xsl:text>&lt;/</xsl:text></xhl:elementbracket>
                    </xsl:when>
                    <xsl:otherwise>
                        <xhl:elementbracket><xsl:text>&lt;</xsl:text></xhl:elementbracket>
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
                            <xsl:value-of select="translate(substring-before($rcode,'&gt;'),'/','')"/>
                        </xhl:elementname>
                    </xsl:otherwise>
                </xsl:choose>
                <xhl:elementbracket>
                    <xsl:choose>
                        <xsl:when test="contains(substring-before($rcode,'&gt;'),'/')">
                            <xsl:text>/&gt;</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>&gt;</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xhl:elementbracket>
                <xsl:call-template name="XMLHighlighter">
                    <xsl:with-param name="code" select="substring-after($rcode,'&gt;')"/>
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="contains('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890',substring($code,1,1))">
                <xhl:elementvalue>
                    <xsl:value-of select="substring-before($code,'&lt;')"/>
                </xhl:elementvalue>
                <xsl:call-template name="XMLHighlighter">
                    <xsl:with-param name="code" select="concat('&lt;',substring-after($code,'&lt;'))"/>
                </xsl:call-template>
            </xsl:when>
            <!-- Newline -->
            <xsl:when test="substring($code,1,1) = '&#xa;'">
                <xh:br/>
                <xsl:choose>
                    <xsl:when test="contains(substring-after($code, substring($code,1,1)),'&lt;')">
                        <xhl:space><xsl:value-of select="substring-before(substring-after($code, substring($code,1,1)),'&lt;')"/></xhl:space>
                        <xsl:call-template name="XMLHighlighter">
                            <xsl:with-param name="code" select="concat('&lt;',substring-after(substring-after($code, substring($code,1,1)),'&lt;'))"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="XMLHighlighter">
                            <xsl:with-param name="code" select="substring-after($code,substring($code,1,1))"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
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
            <xhl:equals><xsl:text>=</xsl:text></xhl:equals>
            <xhl:quote><xsl:text>&quot;</xsl:text></xhl:quote>
            <xhl:attrvalue>
                <xsl:value-of select="substring-before(substring-after($attrs,'=&quot;'),'&quot;')"/>
            </xhl:attrvalue>
            <xhl:quote><xsl:text>&quot;</xsl:text></xhl:quote>
            <xsl:call-template name="XHLAttributes">
                <xsl:with-param name="attrs" select="substring-after(substring-after($attrs,'=&quot;'),'&quot;')"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="XMLHLStyles">
        <xh:style xmlns:xh="http://www.w3.org/1999/xhtml" type="text/css">
            @namespace xhl url("https://apply-templates.com/XMLHL");
            @namespace xh url("http://www.w3.org/1999/xhtml");

            xhl|hl {
                padding: 10px;
                background-color: #eeeeee;
                display:block;
                outline: 1px solid green;
                font-family: "Courier New",monospace;
                font-size: 0;
                overflow-x:auto;
            }

            xhl|hl xhl|elementbracket {
                color: #00539C;
                font-size: 16px;
            }

            xhl|hl xhl|quote {
                color: #00539C;
                font-size: 16px;
            }

            xhl|hl xhl|elementname {
                color: #00539C;
                font-size: 16px;
            }
            xhl|hl xhl|elementvalue {
                color: initial;
                font-size: 16px;
            }
            xhl|hl xhl|equals {
                color: #00539C;
                font-size: 16px;
            }

            xhl|hl xhl|attrname {
                color: #f00000;
                font-size: 16px;
            }
            xhl|hl xhl|attrvalue {
                color: #a31515;
                font-size: 16px;
            }

            xhl|hl xhl|PIBracket {
                color: #00539C;
                font-size: 16px;
            }
            xhl|hl xhl|PIName {
                color: #00539C;
                font-size: 16px;
            }
            xhl|hl xhl|PIString {
                color: #f00000;
                font-size: 16px;
            }

            xhl|hl xhl|commenttext {
                color: #30a14e;
                font-size: 16px;
            }
            xhl|hl xhl|commentbracket {
                color: #30a14e;
                font-size: 16px;
            }
            xhl|space {
                font-size: 16px;
                white-space: pre;
            }
        </xh:style>
    </xsl:template>

</xsl:transform>