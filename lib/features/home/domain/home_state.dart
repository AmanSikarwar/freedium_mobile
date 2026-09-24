class const HomeState({this.url = ''}) {
  final String url;

  HomeState copyWith({String? url}) {
    return HomeState(url: url ?? this.url);
  }
}
