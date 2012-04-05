MobileRemote.App = {}

// eventually this will be one base class that uses a sandbox to
// allow downloaded apps to produce a neat remote UI for webpages

MobileRemote.App.Sandbox = function(remote, name) {
  var self = this;
  
  this.remote = remote;
  this.name = name;
  this.code = null;
  this.filename = '/apps/' + name.replace(/\./g, '/') + '.js';
  this.url = null;
  this.uri = null;
  this.domain = null;
  this.imports = ['lib/zepto', 'lib/json2'];
  this.metadata = {};
  this.sandbox = null;
  
  var init = function() {
    self.code = remote.env.fileContent(self.filename);
    extractMetadata(self.code, setMetadata);
  }
  
  this.render = function(uri, request, response) {
    var sandbox = createSandbox();
    
    var action = request.path.match(/\/([^\/]+)$/)
    if (action) action = action[1];
    
    var limitedRequest = {
      protocol: uri.protocol,
      host: uri.host,
      port: uri.port,
      path: uri.path,
      directory: uri.directory,
      file: uri.file,
      anchor: uri.anchor,
      action: action, 
      params: request.params
    };
    
    var json = Components.utils.evalInSandbox('render(' + JSON.stringify(limitedRequest) + ');', sandbox);
    
    if (typeof json == "string") {
      var hash = JSON.parse(json);
      var c = new MobileRemote.Views.Hash(self, request, response);
      return c.perform(hash);
    } else {
      return null;
    }
  }
  
  var createSandbox = function() {
    var sandbox = Components.utils.Sandbox(self.url);
    sandbox.window = remote.currentBrowser().contentWindow;
    sandbox.document = remote.currentBrowser().contentDocument;
    evalInSandbox('app', 'app = ' + JSON.stringify({name: self.name}), sandbox)
    evalInSandbox('navigator', 'navigator = {userAgent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.5; rv:11.0) Gecko/20100101 Firefox/11.0"}', sandbox);
    
    for (var i=0 ; i < self.imports.length ; i++) {
      var file = '/apps/' + self.imports[i] + '.js';
      var code = remote.env.fileContent(file);
      evalInSandbox(file, code, sandbox);
    }
    
    evalInSandbox('$', '$ = Zepto', sandbox);
    evalInSandbox(self.filename, self.code, sandbox);
    return sandbox;
  }
  
  var evalInSandbox = function(file, code, sandbox) {
    try {
      Components.utils.evalInSandbox(code, sandbox);
    } catch (err) {
      throw file + " " + err;
    }
  }
  
  var extractMetadata = function(code, callback) {
    var regex = /\/\/ \@([^\ ]+)[\ ]+([^\n]+)/g
    
    if (code == null) return null;
    
    var matches = code.match(regex)
    if (matches) {
      for (var i=0 ; i < matches.length ; i++) {
        var match = matches[i];
        var m = match.match(/\/\/ \@([^\ ]+)[\ ]+([^\n]+)/)
        callback(m[1], m[2]);
      }
    }
  }
  
  var setMetadata = function(key, value) {
    switch(key) {
      case 'url':
        self.url = value
        self.uri = new MobileRemote.URI(self.url);
        self.domain = self.uri.host;
        break;
      
      case 'import':
        self.imports.push(value)
        break;
      
      default:
        self.metadata[key] = value
        break;
    }
  }
  
  init();
}
