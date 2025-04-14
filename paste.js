async (clipboardContentString) => {
  // Trim any whitespace from the input
  const input = clipboardContentString.trim();
  
  // Check if the input is a URL (only handle https:// as requested)
  if (input.startsWith('https://')) {
    // Handle Amazon URLs
    if (input.includes('amazon.com') && input.includes('gp/product')) {
      return input.replace('gp/product', 'dp');
    } 
    // Handle YouTube URLs
    else if (input.includes('youtube.com')) {
      // Extract video ID using string operations
      const vIndex = input.indexOf('v=');
      if (vIndex !== -1) {
        let videoId = input.substring(vIndex + 2);
        // Cut off at ampersand if present
        const ampIndex = videoId.indexOf('&');
        if (ampIndex !== -1) {
          videoId = videoId.substring(0, ampIndex);
        }
        return `https://youtube.com/watch?v=${videoId}`;
      }
    }
    // Return original URL if no transformation needed
    return input;
  } else {
    // If not a URL, replace newlines with spaces
    return input.replace(/\n/g, " ");
  }
}
