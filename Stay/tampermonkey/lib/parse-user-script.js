/**
 Source code: https://github.com/greasemonkey/greasemonkey/blob/master/src/parse-user-script.js
 Lincese: https://github.com/greasemonkey/greasemonkey/blob/master/LICENSE.mit
 Github: https://github.com/greasemonkey/greasemonkey
 */


'use strict';

const gAllMetaRegexp = new RegExp(
    '^(\u00EF\u00BB\u00BF)?// ==UserScript==([\\s\\S]*?)^// ==/UserScript==',
    'm');


/** Get just the stuff between ==UserScript== lines. */
function extractMeta(content) {
  const meta = content && content.match(gAllMetaRegexp);
  if (meta) return meta[2].replace(/^\s+/, '');
  return '';
}


// Private implementation.
(function() {

/** Pull the filename part from the URL, without `.user.js`. */
function nameFromUrl(url) {
    native.nslog("nameFromUrl");
  let name = url.substring(0, url.indexOf(".user.js"));
  name = name.substring(name.lastIndexOf("/") + 1);
  return name;
}


// Safely construct a new URL object from a path and base. According to MDN,
// if a URL constructor received an absolute URL as the path then the base
// is ignored. Unfortunately that doesn't seem to be the case. And if the
// base is invalid (null / empty string) then an exception is thrown.
function safeUrl(path, base) {
    //TODO:
    //new URL() seems error in javascriptcore, just return origin path;
    return path;
}

// Defaults that can only be applied after the meta block has been parsed.
function prepDefaults(details) {
  // We couldn't set this default above in case of real data, so if there's
  // still no includes, set the default of include everything.
  if (details.includes.length == 0 && details.matches.length == 0) {
    details.includes.push('*');
  }

  if (details.grants.includes('none') && details.grants.length > 1) {
    details.grants = ['none'];
  }

  return details;
}


/** Parse the source of a script; produce object of data. */
window.parseUserScript = function(content, url, failWhenMissing=false) {
  if (!content) {
    throw new Error('parseUserScript() got no content!');
  }
  
  // Populate with defaults in case the script specifies no value.
  const details = {
      'downloadUrl': '',
      'updateUrl': '',
      'excludes': [],
      'grants': [],
      'homePageUrl': '',
      'author': 'Unnamed Author',
      'includes': [],
      'locales': {},
      'matches': [],
      'name': url && nameFromUrl(url) || 'Unnamed Script',
      'namespace': url && new URL(url).host || '',
      'noFrames': false,
      'requireUrls': [],
      'resourceUrls': {},
      'notes':[],
      'runAt': 'end',
      'pass':true,
      'errorMessage':'',
      'iconUrl':''
  };

  let meta = extractMeta(content).match(/.+/g);
  if (!meta) {
    native.nslog("no meta");
    if (failWhenMissing) {
      throw new Error('Could not parse, no meta.');
    } else {
      details.pass = false;
      details.errorMessage = "no meta";
      return prepDefaults(details);
    }
  }
    

  for (let i = 0, metaLine = ''; metaLine = meta[i]; i++) {
      let data;
      try {
          data = window.parseMetaLine(metaLine.replace(/\s+$/, ''));
      } catch (e) {
          // Ignore invalid/unsupported meta lines.
          continue;
      }
      native.nslog(data.keyword);
      if (UserScriptUnsupport_TAGS.has(data.keyword)){
          details.pass = false;
          details.errorMessage += "Unsupport tag: "+data.keyword+"\n";
          continue;
      }
      
      native.nslog(data.keyword);
      switch (data.keyword) {
          case 'noframes':
              details.noFrames = true;
              break;
          case 'homepageURL':
              details.homePageUrl = data.value;
              break;
          case 'updateURL':
              details.updateUrl = data.value;
              break;
          case 'downloadURL':
              details.downloadUrl = data.value;
              break;
          case 'namespace':
          case 'version':
              details[data.keyword] = data.value;
              break;
          case 'run-at':
              if (RunAtUnsupport_ATTRS.has(data.value)) {
                  details.pass = false;
                  details.errorMessage += 'Unsupport run-at '+data.value+'\n';
              }
              else{
                  details.runAt = data.value.replace('document-', '');
              }
              // TODO: Assert/normalize to supported value.
              break;
          case 'grant':
              if (GM_APIS.has(data.value)) {
                  details.grants.push(data.value);
              }
              else{
                  details.pass = false;
                  details.errorMessage += 'Unsupport GM api '+data.value+'\n';
              }
              break;
          case 'description':
          case 'name':
              let locale = data.locale;
              native.nslog("locale");
              native.nslog(locale);
              if (locale) {
                  if (!details.locales[locale]) details.locales[locale] = {};
                  details.locales[locale][data.keyword] = data.value;
              } else {
                  details[data.keyword] = data.value;
              }
              break;
          case 'exclude':
              details.excludes.push(data.value);
              break;
          case 'include':
              details.includes.push(data.value);
              break;
          case 'note':
              details.notes.push(data.value);
              break;
          case 'match':
              try {
                  new window.MatchPattern(data.value);
                  details.matches.push(data.value);
              } catch (e) {
                  details.errorMessage += 'Unsupport match pattern' + data.value;
              }
              break;
          case 'icon':
              details.iconUrl = data.value;
              break;
          case 'require':
              //hard code cuz only support stay:// now.
//              if (data.value.startsWith('stay://')){
//                  details.requireUrls.push(safeUrl(data.value, url).toString());
//              }
//              else{
//                  details.pass = false;
//                  details.errorMessage += 'Unsupport require protocol: '+data.value;
//              }
              
              details.requireUrls.push(safeUrl(data.value, url).toString());
              
              break;
          case 'resource':
              let resourceName = data.value1;
              let resourceUrl = data.value2;
              if (resourceName in details.resourceUrls) {
                  throw new Error(_('duplicate_resource_NAME', resourceName));
              }
              details.resourceUrls[resourceName] = safeUrl(resourceUrl, url).toString();
              break;
          case 'author':
              details.author = data.value;
              break;
      }
    }
    native.nslog(details);
    return prepDefaults(details);
}

})();

