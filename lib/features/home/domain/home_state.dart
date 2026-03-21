class HomeState {
  final String url;

  const HomeState({this.url = ''});

  HomeState copyWith({String? url}) {
    return HomeState(url: url ?? this.url);
  }
}
