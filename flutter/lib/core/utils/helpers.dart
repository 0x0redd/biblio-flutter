String resolveImageUrl(String url) {
  if (url.startsWith('http://')) {
    return url.replaceFirst('http://', 'https://');
  }
  return url;
}

String greetingForHour(int hour) {
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  return 'Good Evening';
}
