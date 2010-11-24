<?php

# COPYRIGHT:
#  
# This software is Copyright (c) 2007-2008 NETWAYS GmbH, Christian Doebler 
#                                <support@netways.de>
# 
# (Except where explicitly superseded by other copyright notices)
# 
# 
# LICENSE:
# 
# This work is made available to you under the terms of Version 2 of
# the GNU General Public License. A copy of that license should have
# been provided with this software, but in any event can be snarfed
# from http://www.fsf.org.
# 
# This work is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301 or visit their web page on the internet at
# http://www.fsf.org.
# 
# 
# CONTRIBUTION SUBMISSION POLICY:
# 
# (The following paragraph is not intended to limit the rights granted
# to you to modify and distribute this software under the terms of
# the GNU General Public License and is only of importance to you if
# you choose to contribute your changes and enhancements to the
# community by submitting them to NETWAYS GmbH.)
# 
# By intentionally submitting any modifications, corrections or
# derivatives to this work, or any other work intended for use with
# this Software, to NETWAYS GmbH, you confirm that
# you are the copyright holder for those contributions and you grant
# NETWAYS GmbH a nonexclusive, worldwide, irrevocable,
# royalty-free, perpetual, license to use, copy, create derivative
# works based on those contributions, and sublicense and distribute
# those contributions and any derivatives thereof.
#
# Nagios and the Nagios logo are registered trademarks of Ethan Galstad.


class nwTemplate {

	// variables
	private $content = NULL;
	private $html = NULL;
	private $templateFile = NULL;
	private $cacheFile = NULL;
	private $cache = false;
	private $parsed = false;
	private $templateLoaded = false;
	private $cacheExists = false;



	/*
	 * nwTemplate - constructor
	 *
	 * @param	integer		$cache		cache flag
	 * @param	string		$file		template file
	 * @return	boolean				true, cache is true and cache file exists
	 */
	public function nwTemplate ($file = NULL, $cache = NULL) {
		if (isset($cache)) $this->cache = $cache;
		if ($file) $this->setTemplate($file);
		if ($file && $this->cache && $this->checkCache()) {
			$this->cacheExists = true;
			return true;
		}
	}



	/*
	 * assign - add content to array
	 * 
	 * @param	string		$handle		handle for associative array pointing to content
	 * @param	string		$content	content belonging to handle
	 * @return	none
	 */
	public function assign ($handle, $content) {
		$this->content['{$' . $handle . '}'] = $content;
	}



	/*
	 * loadFile - load file
	 * 
	 * @param	none
	 * @return	boolean				true on success, false on error
	 */
	private function loadFile ($type) {

		if ($type == 'template') $file = $this->templateFile;
		else if ($type == 'cache') $file = $this->cacheFile;
		else return false;

		if (file_exists($file)) {
			if (!($fp = fopen($file, 'r'))) return false;
			while (!feof($fp)) {
				if (!($tmp = fread($fp, 1024))) return false; 
				$this->html .= $tmp;
			}
			if (!$fp) return false;
			if (!fclose($fp)) return false; 

		} else return false;

		if ($type == 'template') $this->templateLoaded = true;

		return true;

	}



	/*
	 * parseTemplate - parse the Template and substitute vars
	 * 
	 * @param	none
	 * @return	boolean		true on success, false on error
	 */
	private function parseTemplate ($ignoreEmpty = true) {
		if($this->html) {

			$html = $this->html;
			$end = 0;

			while (($start = strpos($html, '{$', $end)) !== false) {
				$end = strpos($html, '}', $start);
				$length = $end - $start + 1;
				$contentKey = substr($html, $start, $length);
				if (!isset($this->content[$contentKey])) $this->content[$contentKey] = null;
				if ($ignoreEmpty) {
					$html = substr_replace($html, $this->content[$contentKey], $start, $length);
					//unset($this->content[$contentKey]);
				} else {
					if (!isset($this->content[$contentKey])) {
						$html = substr_replace($html, $this->content[$contentKey], $start, $length);
						//unset($this->content[$contentKey]);
					}
				}
				$end = $start + strlen($this->content[$contentKey]);
			}

			$this->html = $html;

		}
		$this->parsed = true;
	}



	/*
	 * setTemplate - set template file
	 *
	 * @param	string		$file		name of template file
	 * @return	none
	 */
	public function setTemplate ($file) {
		$this->templateFile = $file;
		$this->cacheFile = $file . '_nwCache';
	}



	/*
	 * doAll - check and solve (almost) everything
	 *
	 * @param		string		$file	name of template file (optional)
	 * @return		none
	 */
	public function doAll ($file = NULL) {
		if ($this->cacheExists) {
			$this->loadFile('cache');
		} else {
			if ($file && !$this->templateFile) $this->setTemplate($file);
			if ($this->templateFile && !$this->templateLoaded) $this->loadFile('template');
			if (!$this->parsed) $this->parseTemplate(); 
			if ($this->cache) $this->createCacheFile();
		}
	}



	/*
	 * getHTML - return html code
	 *
	 * @param		string		$file	name of template file (optional)
	 * @return		string				parsed HTML code
	 */
	public function getHTML ($file = NULL) {
		$this->doAll();
		return $this->html;
	}



	/*
	 * show - display HTML-code
	 *
	 * @param		string		$file		name of template file (optional)
	 * @return		string					parsed HTML code
	 */
	public function show ($file = NULL) {
		$this->doAll();
		print $this->html;
	}



	/*
	 * createCacheFile - create cache file
	 * 
	 * @param	none
	 * @return	boolean				true on success, false on error
	 */
	private function createCacheFile () {
		if (!($fp = fopen($this->cacheFile, 'w'))) return false;
		if (!fwrite($fp, $this->html)) return false; 
		if (!fclose($fp)) return false; 
		return true;
	}



	/*
	 * disableCache - disable caching
	 *
	 * @param	none
	 * @return	none
	 */
	public function disableCache () {
		$this->cache = false;
	}



	/*
	 * clearCache - clear cache file
	 *
	 * @param	none
	 * @return	boolean				true on success, false on error
	 */
	public function clearCache ($file = NULL) {
		if ($file && !$this->templateFile) $this->setTemplate($file);
		if (!strlen($this->templateFile)) return false;
		if ($this->checkCache()) {
			if (!unlink($this->cacheFile)) return false;				
		}

		$this->cacheExists = false;
		return true;
	}



	/*
	 * checkCache - check whether cache file exists
	 *
	 * @param	none
	 * @return	boolean				true if file exists, else false
	 */
	public function checkCache () {
		if ($this->cacheFile) {
			$this->cacheExists = file_exists($this->cacheFile);
		} else {
			$this->cacheExists = false;
		}
		return $this->cacheExists;
	}



	/*
	 * preParse - parse and don't set the parse flag
	 * 
	 * @param	none
	 * @return	none
	 */
	public function preParse () {
		$this->parseTemplate(false);
		$this->parsed = false;
	}


}

?>
