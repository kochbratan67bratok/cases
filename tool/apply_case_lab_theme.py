#!/usr/bin/env python3
"""Apply the repository's reproducible visual theme patch to the upstream submodule."""
from pathlib import Path
import sys

if len(sys.argv) != 2:
    raise SystemExit("usage: apply_case_lab_theme.py <path-to-CS2-Simulator>")

root = Path(sys.argv[1]).resolve()
main_file = root / "lib" / "main.dart"
home_file = root / "lib" / "presentation" / "screens" / "home_screen.dart"

for path in (main_file, home_file):
    if not path.is_file():
        raise SystemExit(f"expected upstream file not found: {path}")

main = main_file.read_text(encoding="utf-8")
old_theme = "theme: ThemeData.dark(),"
if main.count(old_theme) != 2:
    raise SystemExit(f"expected two default themes in {main_file}, found {main.count(old_theme)}")
if "_caseLabTheme()" in main:
    raise SystemExit("theme patch appears to have already been applied")

main = main.replace(old_theme, "theme: _caseLabTheme(),")
theme_fn = """
ThemeData _caseLabTheme() {
  return ThemeData.dark(useMaterial3: true).copyWith(
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF55D6BE),
      secondary: Color(0xFF8A7DFF),
      surface: Color(0xFF172130),
      error: Color(0xFFFF647C),
    ),
    scaffoldBackgroundColor: const Color(0xFF080C13),
    cardColor: const Color(0xE91A2432),
    dividerColor: Colors.white12,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xF20D121B),
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF55D6BE),
        foregroundColor: const Color(0xFF07110F),
      ),
    ),
  );
}
"""
main_file.write_text(main.rstrip() + "\n\n" + theme_fn.lstrip(), encoding="utf-8")

home = home_file.read_text(encoding="utf-8")
old_body = "      body: LayoutBuilder(\n"
new_body = """      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF080C13),
              Color(0xFF111A28),
              Color(0xFF0A0E16),
            ],
          ),
        ),
        child: LayoutBuilder(
"""
if home.count(old_body) != 1:
    raise SystemExit(f"expected one home body anchor in {home_file}, found {home.count(old_body)}")
home = home.replace(old_body, new_body, 1)
old_end = """          );
        },
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
"""
if home.count(old_end) != 1:
    raise SystemExit("home build end anchor not found")
home = home.replace(old_end, """          );
        },
      )),
    );
  }

  void _push(BuildContext context, Widget screen) {
""", 1)
home_file.write_text(home, encoding="utf-8")
print("Applied Case Lab colors and layered background to upstream Flutter sources.")


# Add the free, 67-level Operation Pass to the upstream simulator at build time.
pass_file = root / "lib" / "presentation" / "screens" / "battle_pass_screen.dart"
progress_file = root / "lib" / "domain" / "battle_pass_progress_service.dart"
tracking_file = root / "lib" / "core" / "collection" / "collection_tracking_service.dart"

progress_source = r"""import 'package:shared_preferences/shared_preferences.dart';

class BattlePassProgressService {
  static const String xpKey = 'case_lab_pass_xp_v1';
  static String _date(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  static String _week(DateTime d) {
    final monday = DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday - 1));
    return _date(monday);
  }
  static String _dailyOpensKey(DateTime d) => 'case_lab_pass_daily_opens_${_date(d)}';
  static String _weeklyOpensKey(DateTime d) => 'case_lab_pass_weekly_opens_${_week(d)}';
  static String _dailyClaimKey(DateTime d) => 'case_lab_pass_daily_claim_${_date(d)}';
  static String _weeklyClaimKey(DateTime d) => 'case_lab_pass_weekly_claim_${_week(d)}';

  static Future<void> addXp(int amount) async {
    final prefs = SharedPreferencesAsync();
    await prefs.setInt(xpKey, (await prefs.getInt(xpKey) ?? 0) + amount);
  }
  static Future<void> recordCaseOpened() async {
    final prefs = SharedPreferencesAsync();
    await addXp(100);
    final now = DateTime.now();
    final dailyKey = _dailyOpensKey(now);
    final weeklyKey = _weeklyOpensKey(now);
    await prefs.setInt(dailyKey, (await prefs.getInt(dailyKey) ?? 0) + 1);
    await prefs.setInt(weeklyKey, (await prefs.getInt(weeklyKey) ?? 0) + 1);
  }
  static Future<int> dailyOpens() async => await SharedPreferencesAsync().getInt(_dailyOpensKey(DateTime.now())) ?? 0;
  static Future<int> weeklyOpens() async => await SharedPreferencesAsync().getInt(_weeklyOpensKey(DateTime.now())) ?? 0;
  static Future<bool> dailyClaimed() async => await SharedPreferencesAsync().getBool(_dailyClaimKey(DateTime.now())) ?? false;
  static Future<bool> weeklyClaimed() async => await SharedPreferencesAsync().getBool(_weeklyClaimKey(DateTime.now())) ?? false;
  static Future<void> markDailyClaimed() async { await SharedPreferencesAsync().setBool(_dailyClaimKey(DateTime.now()), true); }
  static Future<void> markWeeklyClaimed() async { await SharedPreferencesAsync().setBool(_weeklyClaimKey(DateTime.now()), true); }
}
"""

pass_screen_source = r"""import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/collection/collection_tracking_service.dart';
import '../../data/models/container_dto.dart';
import '../../data/models/skin_dto.dart';
import '../../data/repositories/local_data_repository.dart';
import '../../domain/battle_pass_progress_service.dart';
import '../../domain/case_odds.dart';
import '../../domain/container_simulator_service.dart';
import '../helpers/skin_ui_helper.dart';

class BattlePassScreen extends StatefulWidget {
  final LocalDataRepository repository;
  const BattlePassScreen({super.key, required this.repository});
  @override
  State<BattlePassScreen> createState() => _BattlePassScreenState();
}

class _BattlePassScreenState extends State<BattlePassScreen> {
  static const int _maxLevel = 67;
  static const int _xpPerLevel = 500;
  static const int _ticketPrice = 1000;
  static const String _coinsKey = 'case_lab_pass_coins_v1';
  static const String _ticketsKey = 'case_lab_pass_case_tickets_v1';
  static const String _claimedKey = 'case_lab_pass_claimed_levels_v1';
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  final Random _random = Random();
  final ContainerSimulatorService _simulator = ContainerSimulatorService();
  final CollectionTrackingService _tracking = CollectionTrackingService();

  int _xp = 0, _coins = 0, _tickets = 0, _dailyOpens = 0, _weeklyOpens = 0;
  bool _dailyClaimed = false, _weeklyClaimed = false, _busy = false;
  Set<int> _claimed = <int>{};
  List<SkinDto> _knives = <SkinDto>[];
  String? _lastDrop;

  int get _level {
    final value = _xp ~/ _xpPerLevel + 1;
    return value > _maxLevel ? _maxLevel : value;
  }
  double get _levelProgress => _level >= _maxLevel ? 1 : (_xp % _xpPerLevel) / _xpPerLevel;
  int get _xpInLevel => _level >= _maxLevel ? _xpPerLevel : _xp % _xpPerLevel;

  @override
  void initState() { super.initState(); _refresh(); }

  Future<void> _refresh() async {
    final allSkins = await widget.repository.loadSkins();
    final knives = allSkins.where((skin) => skin.isKnife).toList()
      ..sort((a, b) {
        final model = a.itemDisplayName.compareTo(b.itemDisplayName);
        return model != 0 ? model : a.name.compareTo(b.name);
      });
    final claimed = (await _prefs.getStringList(_claimedKey) ?? const <String>[])
        .map(int.parse).toSet();
    final xp = await _prefs.getInt(BattlePassProgressService.xpKey) ?? 0;
    final coins = await _prefs.getInt(_coinsKey) ?? 0;
    final tickets = await _prefs.getInt(_ticketsKey) ?? 0;
    final dailyOpens = await BattlePassProgressService.dailyOpens();
    final weeklyOpens = await BattlePassProgressService.weeklyOpens();
    final dailyClaimed = await BattlePassProgressService.dailyClaimed();
    final weeklyClaimed = await BattlePassProgressService.weeklyClaimed();
    if (!mounted) return;
    setState(() {
      _knives = knives; _claimed = claimed; _xp = xp; _coins = coins; _tickets = tickets;
      _dailyOpens = dailyOpens; _weeklyOpens = weeklyOpens;
      _dailyClaimed = dailyClaimed; _weeklyClaimed = weeklyClaimed;
    });
  }

  int _coinsForLevel(int n) => n == _maxLevel ? 1500 : 100 + n * 15;
  int _ticketsForLevel(int n) => n == _maxLevel ? 1 : n % 10 == 0 ? 2 : n % 5 == 0 ? 1 : 0;
  String _rewardTitle(int n) {
    final coins = _coinsForLevel(n), tickets = _ticketsForLevel(n);
    if (n == _maxLevel) return 'FINAL REWARD · Special Case + $coins coins';
    if (tickets == 2) return '2 case tickets + $coins coins';
    if (tickets == 1) return 'Case ticket + $coins coins';
    return '$coins coins';
  }

  Future<void> _claimLevel(int n) async {
    if (n > _level || _claimed.contains(n)) return;
    final coins = _coins + _coinsForLevel(n);
    final tickets = _tickets + _ticketsForLevel(n);
    final claimed = <int>{..._claimed, n};
    await _prefs.setInt(_coinsKey, coins);
    await _prefs.setInt(_ticketsKey, tickets);
    await _prefs.setStringList(_claimedKey, claimed.map((v) => '$v').toList()..sort());
    if (!mounted) return;
    setState(() { _coins = coins; _tickets = tickets; _claimed = claimed; });
  }

  Future<void> _claimDaily() async {
    if (_dailyClaimed || _dailyOpens < 3) return;
    await BattlePassProgressService.markDailyClaimed();
    await BattlePassProgressService.addXp(250);
    await _refresh();
  }
  Future<void> _claimWeekly() async {
    if (_weeklyClaimed || _weeklyOpens < 10) return;
    await BattlePassProgressService.markWeeklyClaimed();
    await BattlePassProgressService.addXp(1000);
    await _refresh();
  }
  Future<void> _buyTicket() async {
    if (_coins < _ticketPrice || _busy) return;
    final coins = _coins - _ticketPrice, tickets = _tickets + 1;
    await _prefs.setInt(_coinsKey, coins);
    await _prefs.setInt(_ticketsKey, tickets);
    if (mounted) setState(() { _coins = coins; _tickets = tickets; });
  }

  Future<void> _openTicket() async {
    if (_tickets <= 0 || _busy) return;
    setState(() => _busy = true);
    final remaining = _tickets - 1;
    await _prefs.setInt(_ticketsKey, remaining);
    if (mounted) setState(() => _tickets = remaining);
    try {
      final cases = (await widget.repository.loadContainers())
          .where((container) => container.isRegularCase).toList()..shuffle(_random);
      ContainerDto? selected;
      List<SkinDto>? pool;
      for (final candidate in cases) {
        final skins = await widget.repository.loadSkinsForContainer(candidate.id);
        if (skins.isNotEmpty && skins.any((skin) => skin.isSpecialItem)) {
          selected = candidate; pool = skins; break;
        }
      }
      if (selected == null || pool == null) throw StateError('No compatible case pool found.');
      final openedCase = selected;
      final drop = _simulator.openCase(skins: pool, containerDto: openedCase);
      await _tracking.recordSkinDrop(
        drop: drop, sourceName: 'Operation Pass · ${openedCase.name}',
        sourceType: openedCase.typeLabel,
      );
      if (!mounted) return;
      setState(() => _lastDrop = drop.fullDisplayName);
      await _refresh();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('FREE CASE OPENED'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Image.asset(drop.skin.skinImage, height: 130, fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(Icons.inventory_2, size: 72)),
            const SizedBox(height: 10),
            Text(drop.fullDisplayName, textAlign: TextAlign.center,
              style: TextStyle(color: SkinUiHelper.rarityColor(drop.skin), fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(openedCase.name, style: Theme.of(dialogContext).textTheme.bodySmall),
          ]),
          actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('CONTINUE'))],
        ),
      );
    } catch (error) {
      final refund = _tickets;
      await _prefs.setInt(_ticketsKey, refund + 1);
      if (mounted) setState(() { _tickets = refund + 1; _lastDrop = 'Could not open case: $error'; });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showAllKnives() async {
    await showModalBottomSheet<void>(
      context: context, isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(sheetContext).size.height * .82,
          child: Column(children: [
            Padding(padding: const EdgeInsets.all(16), child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('CS2 KNIFE DATABASE (${_knives.length} finishes)', style: Theme.of(sheetContext).textTheme.titleLarge),
                const SizedBox(height: 6),
                const Text('All knife finishes from the simulator data. Valve publishes the 0.256% special-item tier chance for standard cases, not exact percentages for each individual knife. The exact odds depend on the selected case pool.',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            )),
            const Divider(height: 1),
            Expanded(child: ListView.builder(
              itemCount: _knives.length,
              itemBuilder: (context, i) {
                final skin = _knives[i];
                final variant = skin.displayVariant;
                return ListTile(
                  leading: SizedBox(width: 58, child: Image.asset(skin.skinImage, fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(Icons.image_not_supported))),
                  title: Text(skin.itemDisplayName),
                  subtitle: Text(variant == null || variant.isEmpty ? skin.name : '${skin.name} · $variant'),
                  trailing: const Icon(Icons.workspace_premium, color: Colors.amber),
                );
              },
            )),
          ]),
        ),
      ),
    );
  }

  Widget _oddsRow(String label, double chance, Color color) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 9), Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
      Text('${(chance * 100).toStringAsFixed(3)}%', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
    ]),
  );

  Widget _stat(String label, String value, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: .04), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
    child: Row(children: [
      Icon(icon, color: color, size: 20), const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.w800)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
      ])),
    ]),
  );

  Widget _mission(String title, int progress, int target, String reward, bool claimed, VoidCallback action) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
        const SizedBox(height: 5), Text('$progress/$target · $reward', style: const TextStyle(color: Colors.white60, fontSize: 10)),
        const SizedBox(height: 6), LinearProgressIndicator(value: progress / target, minHeight: 4),
      ])),
      const SizedBox(width: 8),
      claimed ? const Icon(Icons.check_circle, color: Color(0xFF55D6BE)) :
        FilledButton(onPressed: progress >= target ? action : null, child: const Text('CLAIM')),
    ]),
  );

  Widget _rewardTile(int n) {
    final unlocked = n <= _level, claimed = _claimed.contains(n);
    final finalLevel = n == _maxLevel, tickets = _ticketsForLevel(n);
    final color = finalLevel ? Colors.amber : n >= 50 ? Colors.purpleAccent : n >= 25 ? Colors.lightBlueAccent : const Color(0xFF55D6BE);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: unlocked ? color.withValues(alpha: .48) : Colors.white10)),
      child: Padding(padding: const EdgeInsets.all(10), child: Row(children: [
        Container(width: 42, height: 44, decoration: BoxDecoration(color: color.withValues(alpha: .13), borderRadius: BorderRadius.circular(10)),
          alignment: Alignment.center, child: Text('$n', style: TextStyle(color: unlocked ? color : Colors.white38, fontWeight: FontWeight.w900))),
        const SizedBox(width: 11),
        Icon(finalLevel ? Icons.workspace_premium : tickets > 0 ? Icons.inventory_2 : Icons.monetization_on, color: unlocked ? color : Colors.white30),
        const SizedBox(width: 9),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_rewardTitle(n), style: TextStyle(fontWeight: FontWeight.w800, color: finalLevel ? Colors.amber : null, fontSize: 12)),
          Text(finalLevel ? 'Real CS2 case pool · authentic rarity odds' : tickets > 0 ? 'Free case opening tickets' : 'Free season reward',
            style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ])),
        if (claimed) const Icon(Icons.check_circle, color: Color(0xFF55D6BE))
        else if (unlocked) TextButton(onPressed: () => _claimLevel(n), child: const Text('CLAIM'))
        else const Icon(Icons.lock_outline, color: Colors.white30),
      ])),
    );
  }

  @override
  Widget build(BuildContext context) {
    final xpToNext = _level == _maxLevel ? 0 : _xpPerLevel - (_xp % _xpPerLevel);
    return Scaffold(
      appBar: AppBar(title: const Text('OPERATION PASS · 67'), actions: [
        IconButton(tooltip: 'Refresh progress', onPressed: _refresh, icon: const Icon(Icons.refresh)),
        IconButton(tooltip: 'All CS2 knives', onPressed: _showAllKnives, icon: const Icon(Icons.content_cut)),
      ]),
      body: RefreshIndicator(onRefresh: _refresh, child: ListView(padding: const EdgeInsets.all(14), children: [
        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF142A32), Color(0xFF211B35), Color(0xFF101722)]),
          border: Border.all(color: Colors.white12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.military_tech, color: Color(0xFF55D6BE), size: 36), const SizedBox(width: 10),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('OPERATION 67', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                Text('FREE REWARD TRACK · NO PREMIUM', style: TextStyle(color: Colors.white60, fontSize: 10, letterSpacing: .7)),
              ])),
              Text('$_level/$_maxLevel', style: const TextStyle(color: Color(0xFF55D6BE), fontWeight: FontWeight.w900)),
            ]),
            const SizedBox(height: 18),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('SEASON XP', style: TextStyle(color: Colors.white60, fontSize: 11)),
              Text('$_xpInLevel/$_xpPerLevel XP', style: const TextStyle(color: Color(0xFF55D6BE), fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(borderRadius: BorderRadius.circular(12), child: LinearProgressIndicator(value: _levelProgress, minHeight: 9, color: const Color(0xFF55D6BE), backgroundColor: Colors.white12)),
            const SizedBox(height: 8),
            Text(_level == _maxLevel ? 'Season completed' : '$xpToNext XP to next level · +100 XP for each case opened',
              style: const TextStyle(color: Colors.white60, fontSize: 11)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _stat('COINS', '$_coins', Icons.monetization_on, Colors.amber)),
              const SizedBox(width: 8),
              Expanded(child: _stat('CASE TICKETS', '$_tickets', Icons.inventory_2, const Color(0xFF55D6BE))),
            ]),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: FilledButton.icon(
              onPressed: _tickets > 0 && !_busy ? _openTicket : null,
              icon: _busy ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.lock_open),
              label: Text(_busy ? 'OPENING…' : 'OPEN FREE CASE'),
            )),
            if (_lastDrop != null) Padding(padding: const EdgeInsets.only(top: 8),
              child: Text('Last drop: $_lastDrop', style: const TextStyle(color: Color(0xFF55D6BE), fontSize: 11))),
          ]),
        ),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('MISSIONS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: .8)),
          const SizedBox(height: 8),
          _mission('Daily: open 3 cases', _dailyOpens.clamp(0, 3).toInt(), 3, '+250 XP', _dailyClaimed, _claimDaily),
          const Divider(height: 18),
          _mission('Weekly: open 10 cases', _weeklyOpens.clamp(0, 10).toInt(), 10, '+1000 XP', _weeklyClaimed, _claimWeekly),
          const SizedBox(height: 6),
          const Text('Any case opened in the simulator counts. Progress is saved on this device.', style: TextStyle(color: Colors.white54, fontSize: 10)),
        ]))),
        Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('CS2 CASE ODDS · REAL RARITY TABLE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: .4)),
          const SizedBox(height: 10),
          _oddsRow('Mil-Spec', CaseOdds.milSpec.chance, Colors.blue),
          _oddsRow('Restricted', CaseOdds.restricted.chance, Colors.purple),
          _oddsRow('Classified', CaseOdds.classified.chance, Colors.pink),
          _oddsRow('Covert', CaseOdds.covert.chance, Colors.red),
          _oddsRow('Special item · knife/gloves', CaseOdds.specialItem.chance, Colors.amber),
          const SizedBox(height: 8),
          const Text('Special item chance is 0.256% per standard case. Exact odds for one knife depend on the selected case and its actual knife/finish pool; Valve does not publish per-knife percentages.',
            style: TextStyle(color: Colors.white60, fontSize: 11, height: 1.35)),
          const SizedBox(height: 12),
          OutlinedButton.icon(onPressed: _showAllKnives, icon: const Icon(Icons.content_cut), label: Text('BROWSE ALL ${_knives.length} KNIFE FINISHES')),
          const SizedBox(height: 8),
          OutlinedButton.icon(onPressed: _coins >= _ticketPrice && !_busy ? _buyTicket : null,
            icon: const Icon(Icons.swap_horiz), label: const Text('EXCHANGE 1000 COINS FOR A CASE TICKET')),
        ]))),
        Row(children: [
          const Expanded(child: Text('FREE REWARD TRACK', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: .8))),
          Text('${_claimed.length}/$_maxLevel claimed', style: const TextStyle(color: Colors.white60, fontSize: 11)),
        ]),
        const SizedBox(height: 10),
        ...List.generate(_maxLevel, (index) => _rewardTile(index + 1)),
        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text(
          'Free offline simulator pass. Knife models and finishes come from the upstream CS2 dataset. Coins are in-game only and are not Steam wallet funds.',
          style: TextStyle(color: Colors.white54, fontSize: 11))),
      ])),
    );
  }
}
"""

if not pass_file.exists():
    pass_file.write_text(pass_screen_source, encoding="utf-8")
if not progress_file.exists():
    progress_file.write_text(progress_source, encoding="utf-8")

if "import 'battle_pass_screen.dart';" not in home:
    home = home.replace("import 'tradeup_screen.dart';", "import 'battle_pass_screen.dart';\nimport 'tradeup_screen.dart';", 1)
trade_up_anchor = """                              title: 'Trade-Up Simulator',
                              subtitle:
                                  'Preview outcomes, floats, and special-item odds',
                              onTap: () => _push(
                                context,
                                TradeUpScreen(repository: repository),
                              ),
                            ),"""
pass_tile = trade_up_anchor + """
                            _ActionTile(
                              icon: Icons.military_tech,
                              title: 'Free Operation Pass · 67 levels',
                              subtitle: 'Coins, free case tickets, missions, and real CS2 knife pools',
                              onTap: () => _push(
                                context,
                                BattlePassScreen(repository: repository),
                              ),
                            ),"""
if "Free Operation Pass · 67 levels" not in home:
    if home.count(trade_up_anchor) != 1:
        raise SystemExit("Could not locate the unique Trade-Up home tile to add Battle Pass")
    home = home.replace(trade_up_anchor, pass_tile, 1)
home_file.write_text(home, encoding="utf-8")

tracking = tracking_file.read_text(encoding="utf-8")
progress_import = "import '../../domain/battle_pass_progress_service.dart';"
if progress_import not in tracking:
    tracking = tracking.replace(
        "import '../../domain/dropped_skin.dart';",
        "import '../../domain/dropped_skin.dart';\n" + progress_import,
        1,
    )
record_anchor = """        patternSeed: drop.patternSeed,
      ),
    );
  }

  Future<void> recordStickerDrop({"""
record_replacement = """        patternSeed: drop.patternSeed,
      ),
    );
    await BattlePassProgressService.recordCaseOpened();
  }

  Future<void> recordStickerDrop({"""
if "await BattlePassProgressService.recordCaseOpened();" not in tracking:
    if tracking.count(record_anchor) != 1:
        raise SystemExit("Could not find the recordSkinDrop completion anchor")
    tracking = tracking.replace(record_anchor, record_replacement, 1)
tracking_file.write_text(tracking, encoding="utf-8")
print("Applied Case Lab theme and added the persistent free 67-level Operation Pass.")
