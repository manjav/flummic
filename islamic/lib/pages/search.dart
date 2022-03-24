import 'package:audio_service/audio_service.dart';
import 'package:autocomplete_textfield_ns/autocomplete_textfield_ns.dart';
import 'package:flutter/material.dart';

import '../models.dart';
import '../utils/localization.dart';
import 'home.dart';

class SearchPage extends StatefulWidget {
  final AudioHandler audioHandler;
  const SearchPage(this.audioHandler, {super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  String pattern = "";
  FocusNode? focusNode;
  List<Search>? results;
  bool assetsLoaded = false;
  AutoCompleteTextField<Word>? textField;
  List<List<String>> get quran => Configs.instance.simpleQuran;
  GlobalKey<AutoCompleteTextFieldState<Word>> key = GlobalKey();

  @override
  void initState() {
    super.initState();
    Configs.instance.loadSearchAssets(() {
      assetsLoaded = true;
      focusNode = FocusNode();
      textField = AutoCompleteTextField<Word>(
          key: key,
          minLength: 2,
          focusNode: focusNode,
          textInputAction: TextInputAction.none,
          decoration: InputDecoration(
              hintText: "search_in".l(), suffixIcon: const Icon(Icons.search)),
          controller: TextEditingController(),
          suggestionsAmount: 12,
          suggestions: Configs.instance.words,
          itemBuilder: suggestionBuilder,
          itemSorter: (a, b) => b.c! - a.c!,
          itemFilter: (w, t) => w.t!.contains(t),
          clearOnSubmit: false,
          itemSubmitted: (Word w) => setState(() => results = search(w.t!)));
      focusNode!.requestFocus();
      setState(() {});
    });
    results = <Search>[];
  }

  Widget suggestionBuilder(BuildContext context, Word item) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        height: 40,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(item.t!), Text(item.c!.n())]));
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: textField ?? const SizedBox()),
        body: ListView.builder(
            itemBuilder: (BuildContext c, int i) => _itemBuilder(c, theme, i),
            itemCount: results!.length));
  }

  Widget _itemBuilder(BuildContext context, ThemeData theme, int index) {
    var s = results![index];
    var max = 58;
    var t = quran[s.sura][s.aya];
    var end = s.index + pattern.length + max;
    var pre = t.substring((s.index - max).clamp(0, s.index), s.index);
    var text = t.substring(s.index, s.index + pattern.length);
    var post = t.substring(s.index + pattern.length, end.clamp(0, t.length));
    if (s.index > max) pre = "... $pre";
    if (t.length - s.index > max) post = "$post ...";
    return Container(
        color: index % 2 == 0 ? theme.colorScheme.background : theme.cardColor,
        child: GestureDetector(
            onTap: () {
              var p = Configs.instance.getPart(s.sura, s.aya);
              HomePageState.selectedPage = p[0];
              HomePageState.selectedIndex = p[1];
              Prefs.instance.setInt("last", p[2]);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomePage(widget.audioHandler)));
            },
            child: Padding(
                padding:
                    const EdgeInsets.only(top: 10, right: 16, bottom: 5, left: 16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                          "${(index + 1).n()}. ${'sura_l'.l()} ${Configs.instance.metadata.suras[s.sura].name} - ${'aya_l'.l()} ${(s.aya + 1).n()}"),
                      RichText(
                        textAlign: TextAlign.justify,
                        textDirection: TextDirection.rtl,
                        text: TextSpan(
                          style: theme.textTheme.bodySmall,
                          children: [
                            TextSpan(text: pre),
                            TextSpan(
                                text: text, style: theme.textTheme.titleMedium),
                            TextSpan(text: post),
                          ],
                        ),
                      )
                    ]))));
  }

  List<Search> search(String pattern) {
    var result = <Search>[];
    if (pattern.isEmpty) return result;
    this.pattern = pattern.toLowerCase();
    for (var s = 0; s < quran.length; s++) {
      for (var a = 0; a < quran[s].length; a++) {
        var i = quran[s][a].toLowerCase().indexOf(pattern);
        if (i > -1) result.add(Search(s, a, i));
      }
    }
    return result;
  }

  @override
  void dispose() {
    focusNode!.dispose();
    super.dispose();
  }
}
