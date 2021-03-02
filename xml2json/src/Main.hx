class Main {
	static var paths = [
		"sq.nahi", "sq.mehdiu", "sq.ahmeti", "ber.mensur", "ar.jalalayn", "ar.muyassar", "am.sadiq", "az.mammadaliyev", "az.musayev", "bn.hoque",
		"bn.bengali", "bs.korkut", "bs.mlivo", "bg.theophanov", "zh.jian", "zh.majian", "cs.hrbek", "cs.nykl", "dv.divehi", "nl.keyzer", "nl.leemhuis",
		"nl.siregar", "en.ahmedali", "en.ahmedraza", "en.arberry", "en.daryabadi", "en.hilali", "en.itani", "en.maududi", "en.pickthall", "en.qarai",
		"en.qaribullah", "en.sahih", "en.sarwar", "en.shakir", "en.transliteration", "en.wahiduddin", "en.yusufali", "fr.hamidullah", "de.aburida",
		"de.bubenheim", "de.khoury", "de.zaidan", "ha.gumi", "hi.farooq", "hi.hindi", "id.indonesian", "id.muntakhab", "id.jalalayn", "it.piccardo",
		"ja.japanese", "ko.korean", "ku.asan", "ms.basmeih", "ml.abdulhameed", "ml.karakunnu", "no.berg", "fa.ghomshei", "fa.ansarian", "fa.ayati",
		"fa.bahrampour", "fa.khorramdel", "fa.khorramshahi", "fa.sadeqi", "fa.fooladvand", "fa.gharaati", "fa.nemooneh", "fa.mojtabavi", "fa.moezzi",
		"fa.makarem", "pl.bielawskiego", "pt.elhayek", "ro.grigore", "ru.abuadel", "ru.muntahab", "ru.krachkovsky", "ru.kuliev", "ru.kuliev_alsaadi",
		"ru.osmanov", "ru.porokhova", "ru.sablukov", "sd.amroti", "so.abduh", "es.bornez", "es.cortes", "es.garcia", "sw.barwani", "sv.bernstrom", "tg.ayati",
		"ta.tamil", "tt.nugman", "th.thai", "tr.golpinarli", "tr.bulac", "tr.transliteration", "tr.diyanet", "tr.vakfi", "tr.yuksel", "tr.yazir", "tr.ozturk",
		"tr.yildirim", "tr.ates", "ur.maududi", "ur.kanzuliman", "ur.ahmedali", "ur.jalandhry", "ur.qadri", "ur.jawadi", "ur.junagarhi", "ur.najafi",
		"ug.saleh", "uz.sodik"
	];
	static var fileIndex = 0;

	static function main() {
		load();
	}

	static function load() {
		if (fileIndex >= paths.length) {
			trace(paths.length , "finish");
			return;
		}

		var http = new haxe.Http("http://tanzil.net/trans/?transID=" + paths[fileIndex] + "&type=xml");
		http.onData = http_onData;
		http.onError = function(error) {
			trace('loading ' + paths[fileIndex] + ' failed.');
			fileIndex++;
			load();
		}
		http.request();
	}

	static function http_onData(str:String) {
		fileIndex++;
		load();
	}
}
