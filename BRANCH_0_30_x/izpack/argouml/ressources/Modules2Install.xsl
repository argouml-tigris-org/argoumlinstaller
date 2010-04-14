<?xml version="1.0" encoding="utf-8"?>
<!--
	Author: L.Maitre
	File: Modules2Install.xsl
	Date: 2006/01/28
	Purpose: Transform a module descriptor file to IzPack packs descriptors
-->
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>
	<xsl:output method="xml" indent="yes" encoding="utf-8" 
	omit-xml-declaration="yes"/>
	<xsl:strip-space elements="*" />
	
	<xsl:param name="argo-ext-dir">@ARGO_EXT@</xsl:param>
	
	<xsl:template match="/">
		<xsl:for-each select="//module">
			<xsl:apply-templates select="."/>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="module">
	     <pack name="{@name}" required="no">
	     	<xsl:choose>
	     	<xsl:when test="./@selected = 'true'">
	     		<xsl:attribute name="preselected">yes</xsl:attribute>
	     	</xsl:when>
	     	<xsl:otherwise>
	     		<xsl:attribute name="preselected">no</xsl:attribute>
	     	</xsl:otherwise>
	     	</xsl:choose>
            <description><xsl:value-of select="."/></description>
            <fileset dir="{$argo-ext-dir}" targetdir="$INSTALL_PATH/ext">
	            	<include name="{@file}"/>	
            </fileset>
         </pack>
	</xsl:template>
</xsl:stylesheet>