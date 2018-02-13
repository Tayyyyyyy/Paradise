class Message {
  constructor(message, messageId, preventLink=false, count=1) {
    // Basically we url_encode twice server side so we can manually read the encoded version and actually do UTF-8.
    // The replace for + is because FOR SOME REASON, BYOND replaces spaces with a + instead of %20, and a plus with %2b.
    // Marvelous.
    message = message.replace(/\+/g, "%20");
    message = decodeURIComponent(message);
    this.message = message;
    this.messageId = messageId;
    this.preventLink = preventLink;
    this.count = count;
    this.process = this.process.bind(this);
  }
  //Shit fucking piece of crap that doesn't work god fuckin damn it
  linkify(text) {
    const rex = /((?:<a|<iframe|<img)(?:.*?(?:src=["']|href=["']).*?))?(?:(?:https?:\/\/)|(?:www\.))+(?:[^ ]*?\.[^ ]*?)+[-A-Za-z0-9+&@#\/%?=~_|$!:,.;]+/ig;
    return text.replace(rex, function ($0, $1) {
      if(/^https?:\/\/.+/i.test($0)) {
	return $1 ? $0: '<a href="'+$0+'">'+$0+'</a>';
      }
      else {
	return $1 ? $0: '<a href="http://'+$0+'">'+$0+'</a>';
      }
    });
  }

  process() {
    if (this.preventLink) {
      return this.message;
    }
    return this.linkify(this.message);
  }
}

export default Message;
