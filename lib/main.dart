import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const CaseSimulatorApp());

class CaseSimulatorApp extends StatelessWidget {
  const CaseSimulatorApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Case Lab', debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, brightness: Brightness.dark, scaffoldBackgroundColor: const Color(0xFF10141D), colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF55D6BE), brightness: Brightness.dark)),
    home: const CaseHomePage(),
  );
}

class Skin {
  const Skin(this.name, this.weapon, this.rarity, this.value, this.color, this.icon);
  final String name, weapon, rarity;
  final double value;
  final Color color;
  final IconData icon;
}

const skins = <Skin>[
 Skin('Sand Dune','Glock-18','Consumer Grade',0.12,Color(0xFFB0C3D9),Icons.gps_fixed),
 Skin('Forest Leaves','MP7','Consumer Grade',0.18,Color(0xFFB0C3D9),Icons.park),
 Skin('Carbon Fiber','P250','Industrial Grade',0.45,Color(0xFF5E98D9),Icons.grid_4x4),
 Skin('Oceanic','Nova','Industrial Grade',0.62,Color(0xFF5E98D9),Icons.waves),
 Skin('Neon Rider','MAC-10','Mil-Spec',2.40,Color(0xFF4B69FF),Icons.bolt),
 Skin('Mecha Industries','M4A1-S','Mil-Spec',4.80,Color(0xFF4B69FF),Icons.precision_manufacturing),
 Skin('Redline','AK-47','Restricted',8.50,Color(0xFF8847FF),Icons.local_fire_department),
 Skin('Hyper Beast','AWP','Restricted',13.00,Color(0xFF8847FF),Icons.pets),
 Skin('Printstream','Desert Eagle','Classified',27.00,Color(0xFFD32CE6),Icons.auto_awesome),
 Skin('Vaporwave','M4A1-S','Classified',39.00,Color(0xFFD32CE6),Icons.blur_on),
 Skin('Crimson Web','Karambit','Covert',145.00,Color(0xFFEB4B4B),Icons.change_history),
 Skin('Fade','Butterfly Knife','Covert',280.00,Color(0xFFEB4B4B),Icons.air),
 Skin('Doppler','Karambit','Rare Special Item',520.00,Color(0xFFFFD700),Icons.star),
];

class CaseInfo {
 const CaseInfo(this.name,this.price,this.subtitle,this.color);
 final String name,subtitle;
 final double price;
 final Color color;
}
const caseList = <CaseInfo>[
 CaseInfo('Recoil Case',4.50,'A little kick of color',Color(0xFF45A29E)),
 CaseInfo('Spectrum Case',8.00,'Bright skins, big dreams',Color(0xFF7B61FF)),
 CaseInfo('Shadow Case',12.00,'Something rare in the dark',Color(0xFFE29B45)),
];
class OwnedSkin { const OwnedSkin(this.skin,this.id); final Skin skin; final int id; }

class CaseHomePage extends StatefulWidget {
 const CaseHomePage({super.key});
 @override State<CaseHomePage> createState() => _CaseHomePageState();
}
class _CaseHomePageState extends State<CaseHomePage> with SingleTickerProviderStateMixin {
 final _random = Random();
 final List<OwnedSkin> _inventory = [];
 late final AnimationController _animation;
 double _balance = 100;
 CaseInfo _selected = caseList.first;
 Skin? _drop;
 bool _opening = false;
 int _nextId = 0;
 String _status = 'Choose a case and try your luck';
 @override void initState() { super.initState(); _animation = AnimationController(vsync: this,duration: const Duration(milliseconds: 700)); }
 @override void dispose() { _animation.dispose(); super.dispose(); }
 Skin _roll() {
   final n = _random.nextInt(1000);
   final rarity = n < 450 ? 'Consumer Grade' : n < 700 ? 'Industrial Grade' : n < 870 ? 'Mil-Spec' : n < 950 ? 'Restricted' : n < 985 ? 'Classified' : n < 998 ? 'Covert' : 'Rare Special Item';
   final options = skins.where((s) => s.rarity == rarity).toList();
   return options[_random.nextInt(options.length)];
 }
 Future<void> _openCase() async {
   if (_opening) return;
   if (_balance < _selected.price) { setState(() => _status = 'Not enough virtual balance. Sell an item or choose a cheaper case.'); return; }
   setState(() { _opening = true; _balance -= _selected.price; _drop = null; _status = 'Opening ' + _selected.name + '…'; });
   await _animation.forward(from: 0);
   final item = _roll();
   if (!mounted) return;
   setState(() { _drop = item; _inventory.insert(0, OwnedSkin(item,++_nextId)); _opening = false; _status = 'You got ' + item.name + '!'; });
 }
 void _sell(OwnedSkin item) => setState(() { _inventory.remove(item); _balance += item.skin.value; _status = 'Sold ' + item.skin.name + ' for $' + item.skin.value.toStringAsFixed(2); });
 void _sellAll() { final total = _inventory.fold<double>(0,(sum,item) => sum + item.skin.value); setState(() { _inventory.clear(); _balance += total; _status = 'Sold all items for $' + total.toStringAsFixed(2); }); }
 @override Widget build(BuildContext context) => Scaffold(body: SafeArea(child: CustomScrollView(slivers: [
   SliverToBoxAdapter(child: _header()), SliverToBoxAdapter(child: _hero()), SliverToBoxAdapter(child: _caseSelector()), SliverToBoxAdapter(child: _dropPanel()), SliverToBoxAdapter(child: _inventoryTitle()),
   if (_inventory.isEmpty) const SliverToBoxAdapter(child: _emptyInventory()) else SliverPadding(padding: const EdgeInsets.fromLTRB(16,0,16,28),sliver: SliverGrid(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,childAspectRatio: 1.25,crossAxisSpacing: 12,mainAxisSpacing: 12),delegate: SliverChildBuilderDelegate((context,index) => _inventoryCard(_inventory[index]),childCount: _inventory.length))),
 ])));
 Widget _header() => Padding(padding: const EdgeInsets.fromLTRB(20,16,20,8),child: Row(children: [Container(width:42,height:42,decoration:BoxDecoration(color:const Color(0xFF55D6BE).withValues(alpha:.14),borderRadius:BorderRadius.circular(13)),child:const Icon(Icons.all_inbox,color:Color(0xFF55D6BE))),const SizedBox(width:12),const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('CASE LAB',style:TextStyle(fontWeight:FontWeight.w900,letterSpacing:2)),Text('CS2 CASE SIMULATOR',style:TextStyle(color:Colors.white54,fontSize:10,letterSpacing:1.2))])),Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:9),decoration:BoxDecoration(color:const Color(0xFF202735),borderRadius:BorderRadius.circular(12)),child:Row(children:[const Icon(Icons.account_balance_wallet,color:Color(0xFF55D6BE),size:17),const SizedBox(width:7),Text('$'+_balance.toStringAsFixed(2),style:const TextStyle(fontWeight:FontWeight.bold))]))]));
 Widget _hero() => Padding(padding:const EdgeInsets.fromLTRB(16,14,16,18),child:Container(width:double.infinity,padding:const EdgeInsets.all(20),decoration:BoxDecoration(borderRadius:BorderRadius.circular(24),gradient:const LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xFF263B48),Color(0xFF19212F),Color(0xFF171B27)]),border:Border.all(color:const Color(0xFF55D6BE).withValues(alpha:.25))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('YOUR NEXT\nBIG DROP?',style:TextStyle(fontSize:30,height:1.05,fontWeight:FontWeight.w900)),const SizedBox(height:10),const Text('Open cases. Collect skins. Build your inventory.',style:TextStyle(color:Colors.white60)),const SizedBox(height:20),Row(children:[const Icon(Icons.bolt,color:Color(0xFF55D6BE),size:18),const SizedBox(width:6),Text(_inventory.length.toString()+' ITEMS COLLECTED',style:const TextStyle(fontSize:11,fontWeight:FontWeight.bold,letterSpacing:1)),const Spacer(),const Text('SIMULATION ONLY',style:TextStyle(color:Colors.white38,fontSize:9,letterSpacing:.8))]) ])));
 Widget _caseSelector() => Padding(padding:const EdgeInsets.fromLTRB(16,0,16,10),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('SELECT A CASE',style:TextStyle(fontWeight:FontWeight.w900,letterSpacing:1.5,fontSize:12)),const SizedBox(height:12),SizedBox(height:142,child:ListView.separated(scrollDirection:Axis.horizontal,itemCount:caseList.length,separatorBuilder:(_,__)=>const SizedBox(width:12),itemBuilder:(context,index){final item=caseList[index];final selected=item==_selected;return GestureDetector(onTap:_opening?null:()=>setState((){_selected=item;_drop=null;_status='Ready to open '+item.name;}),child:AnimatedContainer(duration:const Duration(milliseconds:180),width:142,padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:selected?item.color.withValues(alpha:.18):const Color(0xFF1A202C),borderRadius:BorderRadius.circular(18),border:Border.all(color:selected?item.color:Colors.white10,width:selected?1.5:1)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(Icons.inventory_2_rounded,color:item.color,size:30),const Spacer(),Text(item.name,style:const TextStyle(fontWeight:FontWeight.bold)),Text(item.subtitle,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:10,color:Colors.white54)),const SizedBox(height:5),Text('$'+item.price.toStringAsFixed(2),style:TextStyle(color:item.color,fontWeight:FontWeight.w900))])));}))]));
 Widget _dropPanel() => Padding(padding:const EdgeInsets.fromLTRB(16,10,16,22),child:Container(width:double.infinity,padding:const EdgeInsets.fromLTRB(18,20,18,18),decoration:BoxDecoration(color:const Color(0xFF181E29),borderRadius:BorderRadius.circular(22),border:Border.all(color:Colors.white10)),child:Column(children:[ScaleTransition(scale:CurvedAnimation(parent:_animation,curve:Curves.elasticOut),child:Container(width:112,height:112,decoration:BoxDecoration(shape:BoxShape.circle,color:(_drop?.color??_selected.color).withValues(alpha:.12),border:Border.all(color:(_drop?.color??_selected.color).withValues(alpha:.6),width:2)),child:Icon(_opening?Icons.hourglass_top_rounded:(_drop?.icon??Icons.inventory_2_rounded),size:54,color:_drop?.color??_selected.color))),const SizedBox(height:15),Text(_drop?.name??_selected.name,textAlign:TextAlign.center,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:20)),const SizedBox(height:5),Text(_drop?.weapon??_selected.subtitle,style:TextStyle(color:_drop?.color??Colors.white54,fontSize:12,fontWeight:FontWeight.w600)),if(_drop!=null)...[const SizedBox(height:7),Text(_drop!.rarity.toUpperCase(),style:TextStyle(color:_drop!.color,fontSize:10,letterSpacing:1.2,fontWeight:FontWeight.bold)),const SizedBox(height:4),Text('Estimated value: $'+_drop!.value.toStringAsFixed(2),style:const TextStyle(fontWeight:FontWeight.bold))],const SizedBox(height:13),Text(_status,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white54,fontSize:12)),const SizedBox(height:18),SizedBox(width:double.infinity,height:52,child:FilledButton.icon(onPressed:_opening?null:_openCase,icon:Icon(_opening?Icons.hourglass_empty:Icons.lock_open_rounded),label:Text(_opening?'OPENING…':'OPEN CASE  ·  $'+_selected.price.toStringAsFixed(2)),style:FilledButton.styleFrom(backgroundColor:const Color(0xFF55D6BE),foregroundColor:const Color(0xFF10141D),textStyle:const TextStyle(fontWeight:FontWeight.w900,letterSpacing:.4),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(15))))),const SizedBox(height:8),const Text('Virtual balance only. No real money or real items.',style:TextStyle(fontSize:10,color:Colors.white38))])));
 Widget _inventoryTitle() => Padding(padding:const EdgeInsets.fromLTRB(20,0,20,14),child:Row(children:[const Expanded(child:Text('YOUR INVENTORY',style:TextStyle(fontWeight:FontWeight.w900,letterSpacing:1.4,fontSize:12))),if(_inventory.isNotEmpty)TextButton.icon(onPressed:_sellAll,icon:const Icon(Icons.sell_outlined,size:16),label:const Text('Sell all'))]));
 static Widget _emptyInventory() => Padding(padding:const EdgeInsets.fromLTRB(24,4,24,30),child:Column(children:[Icon(Icons.inventory_2_outlined,size:42,color:Colors.white.withValues(alpha:.2)),const SizedBox(height:10),const Text('Your inventory is empty',style:TextStyle(color:Colors.white60,fontWeight:FontWeight.w600)),const SizedBox(height:4),const Text('Open your first case to collect a skin.',style:TextStyle(color:Colors.white38,fontSize:12))]));
 Widget _inventoryCard(OwnedSkin item) => Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:const Color(0xFF1A202C),borderRadius:BorderRadius.circular(18),border:Border.all(color:item.skin.color.withValues(alpha:.5))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Icon(item.skin.icon,color:item.skin.color,size:28),const Spacer(),Container(width:7,height:7,decoration:BoxDecoration(color:item.skin.color,shape:BoxShape.circle))]),const Spacer(),Text(item.skin.name,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.bold)),Text(item.skin.weapon,style:const TextStyle(color:Colors.white54,fontSize:11)),const SizedBox(height:6),Row(children:[Expanded(child:Text('$'+item.skin.value.toStringAsFixed(2),style:TextStyle(color:item.skin.color,fontWeight:FontWeight.w900))),InkWell(onTap:()=>_sell(item),borderRadius:BorderRadius.circular(8),child:const Padding(padding:EdgeInsets.all(5),child:Icon(Icons.sell_outlined,size:17,color:Colors.white70))) ] )]));
}
