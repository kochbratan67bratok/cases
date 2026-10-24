import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const CaseSimulatorApp());
const mint = Color(0xFF55D6BE), bg = Color(0xFF10141D), panel = Color(0xFF1A202C), muted = Color(0xFF9AA5B5);

class CaseSimulatorApp extends StatelessWidget {
  const CaseSimulatorApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(
    title: 'Case Lab', debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, brightness: Brightness.dark, scaffoldBackgroundColor: bg, colorScheme: ColorScheme.fromSeed(seedColor: mint, brightness: Brightness.dark)),
    home: const GameShell(),
  );
}
class Skin {
  const Skin(this.name,this.weapon,this.rarity,this.value,this.color,this.icon);
  final String name,weapon,rarity; final double value; final Color color; final IconData icon;
}
const skins = <Skin>[
 Skin('Sand Dune','Glock-18','Consumer',.12,Color(0xFFB0C3D9),Icons.gps_fixed),
 Skin('Forest Leaves','MP7','Consumer',.18,Color(0xFFB0C3D9),Icons.park),
 Skin('Carbon Fiber','P250','Industrial',.45,Color(0xFF5E98D9),Icons.grid_4x4),
 Skin('Oceanic','Nova','Industrial',.62,Color(0xFF5E98D9),Icons.waves),
 Skin('Neon Rider','MAC-10','Mil-Spec',2.4,Color(0xFF4B69FF),Icons.bolt),
 Skin('Mecha Industries','M4A1-S','Mil-Spec',4.8,Color(0xFF4B69FF),Icons.precision_manufacturing),
 Skin('Redline','AK-47','Restricted',8.5,Color(0xFF8847FF),Icons.local_fire_department),
 Skin('Hyper Beast','AWP','Restricted',13,Color(0xFF8847FF),Icons.pets),
 Skin('Printstream','Desert Eagle','Classified',27,Color(0xFFD32CE6),Icons.auto_awesome),
 Skin('Vaporwave','M4A1-S','Classified',39,Color(0xFFD32CE6),Icons.blur_on),
 Skin('Crimson Web','Karambit','Covert',145,Color(0xFFEB4B4B),Icons.change_history),
 Skin('Fade','Butterfly Knife','Covert',280,Color(0xFFEB4B4B),Icons.air),
 Skin('Doppler','Karambit','Rare special',520,Color(0xFFFFD700),Icons.star),
];
class CaseInfo {
 const CaseInfo(this.name,this.price,this.subtitle,this.color,this.icon);
 final String name,subtitle; final double price; final Color color; final IconData icon;
}
const caseList=<CaseInfo>[
 CaseInfo('Recoil Case',4.5,'A little kick of color',Color(0xFF45A29E),Icons.bolt),
 CaseInfo('Spectrum Case',8,'Bright skins, big dreams',Color(0xFF7B61FF),Icons.blur_on),
 CaseInfo('Shadow Case',12,'Something rare in the dark',Color(0xFFE29B45),Icons.nights_stay),
 CaseInfo('Dreams & Nightmares',18,'Pick your side',Color(0xFF43A6E8),Icons.dark_mode),
];
class OwnedSkin { OwnedSkin(this.skin,this.id); final Skin skin; final int id; }
class Mission {
 Mission(this.title,this.desc,this.goal,this.reward,this.icon);
 final String title,desc; final int goal,reward; final IconData icon;
 int progress=0; bool claimed=false;
 bool get complete=>progress>=goal;
}
class GameShell extends StatefulWidget { const GameShell({super.key}); @override State<GameShell> createState()=>_GameShellState(); }
class _GameShellState extends State<GameShell> {
 final random=Random(); final inventory=<OwnedSkin>[];
 late final missions=<Mission>[
  Mission('First drop','Open 1 case',1,80,Icons.inventory_2),
  Mission('Collector','Open 3 cases',3,180,Icons.collections),
  Mission('Big spender','Sell skins worth 10 credits',10,220,Icons.sell),
  Mission('Season grinder','Earn 500 season XP',500,250,Icons.bolt),
 ];
 final claimedLevels=<int>{};
 int duelRounds=3,duelCount=0,duelWins=0; bool duelRunning=false; List<Skin> duelPlayerDrops=[],duelBotDrops=[]; String duelResult='Create a duel against the bot.';
 OwnedSkin? upgradeSource; Skin? upgradeTarget; int upgradeAttempts=0,upgradeWins=0; final upgradeHistory=<String>[];
 int tab=0,xp=0,opened=0,serial=0,soldCredits=0; double balance=100;
 bool opening=false; Skin? lastDrop; CaseInfo selected=caseList.first;
 final ScrollController _rollerController=ScrollController();
 final GlobalKey _rollerViewportKey=GlobalKey();
 List<Skin> rollItems=[]; int? rollWinnerIndex;
 static const int _winnerSlot=28;
 String status='Choose a case and try your luck';
 int get level=>xp~/1000+1; int get levelXp=>xp%1000;
 double get progress=>levelXp/1000;
 void earnXp(int amount){ xp+=amount; for(final m in missions.where((m)=>m.title=='Season grinder')){m.progress=xp.clamp(0,m.goal);} }
 Skin roll(){
  final n=random.nextInt(1000);
  final rarity=n<450?'Consumer':n<700?'Industrial':n<870?'Mil-Spec':n<950?'Restricted':n<985?'Classified':n<998?'Covert':'Rare special';
  final pool=skins.where((s)=>s.rarity==rarity).toList();
  return pool[random.nextInt(pool.length)];
 }
 Future<void> openCase() async {
  if(opening)return;
  if(balance<selected.price){setState(()=>status='Not enough virtual credits. Sell a skin first.');return;}
  final drop=roll();
  final sequence=List<Skin>.generate(38,(_)=>roll());
  sequence[_winnerSlot]=drop;
  setState(() {
   opening=true; balance-=selected.price; lastDrop=null;
   rollItems=sequence; rollWinnerIndex=_winnerSlot;
   status='Opening ${selected.name}…';
  });
  await WidgetsBinding.instance.endOfFrame;
  if(!mounted)return;
  if(_rollerController.hasClients){
   _rollerController.jumpTo(0);
   final renderObject=_rollerViewportKey.currentContext?.findRenderObject();
   final viewportWidth=renderObject is RenderBox ? renderObject.size.width : MediaQuery.of(context).size.width-56;
   const itemWidth=118.0, itemGap=10.0, horizontalPadding=12.0;
   final target=horizontalPadding+_winnerSlot*(itemWidth+itemGap)+itemWidth/2-viewportWidth/2;
   final maxExtent=_rollerController.position.maxScrollExtent;
   await _rollerController.animateTo(target.clamp(0.0,maxExtent).toDouble(),duration:const Duration(milliseconds:3200),curve:Curves.easeOutCubic);
  } else {
   await Future<void>.delayed(const Duration(milliseconds:3200));
  }
  if(!mounted)return;
  setState((){
   opening=false;lastDrop=drop;inventory.insert(0,OwnedSkin(drop,++serial));opened++;earnXp(100);
   for(final m in missions.where((m)=>m.title=='First drop'||m.title=='Collector')){m.progress++;}
   status='You got ${drop.name}!';
  });
 }
 @override void dispose(){ _rollerController.dispose(); super.dispose(); }
 Widget openingRoller()=>SizedBox(
  height:160,
  child:Stack(children:[
   ListView.builder(
    key:_rollerViewportKey,
    controller:_rollerController,
    scrollDirection:Axis.horizontal,
    physics:const NeverScrollableScrollPhysics(),
    padding:const EdgeInsets.symmetric(horizontal:12),
    itemCount:rollItems.length,
    itemBuilder:(context,index){
     final item=rollItems[index];
     final isWinner=!opening&&index==rollWinnerIndex;
     return Container(
      width:118,
      margin:const EdgeInsets.only(right:10),
      child:AnimatedContainer(
       duration:const Duration(milliseconds:180),
       padding:const EdgeInsets.all(9),
       decoration:BoxDecoration(
        color:item.color.withValues(alpha:isWinner ? 0.22 : 0.08),
        borderRadius:BorderRadius.circular(14),
        border:Border.all(color:isWinner?Colors.white:item.color.withValues(alpha:.75),width:isWinner?2.5:1.2),
        boxShadow:isWinner?[BoxShadow(color:item.color.withValues(alpha:.35),blurRadius:16)]:null,
       ),
       child:Column(children:[
        Icon(item.icon,size:34,color:item.color),
        const Spacer(),
        Text(item.name,textAlign:TextAlign.center,maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:11,fontWeight:FontWeight.w900)),
        const SizedBox(height:3),
        Text(item.weapon,textAlign:TextAlign.center,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:10,color:muted)),
        const SizedBox(height:5),
        Text(item.value.toStringAsFixed(2),style:TextStyle(fontSize:11,color:item.color,fontWeight:FontWeight.w900)),
       ]),
      ),
     );
    },
   ),
   Positioned.fill(child:IgnorePointer(child:Center(child:Container(
    width:3,height:138,
    decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(4),boxShadow:const [BoxShadow(color:Colors.white54,blurRadius:8)]),
   )))),
  ]),
 );
 void sell(OwnedSkin item){setState((){
  inventory.remove(item);balance+=item.skin.value;soldCredits+=item.skin.value.ceil();earnXp(10);
  for(final m in missions.where((m)=>m.title=='Big spender')){m.progress=soldCredits.clamp(0,m.goal);}
  status='Sold ${item.skin.name} for ${item.skin.value.toStringAsFixed(2)}';
 });}
 void claimMission(Mission m){if(!m.complete||m.claimed)return;setState(() { m.claimed=true; balance+=m.reward; });}
 void claimLevel(int n){if(n>level||claimedLevels.contains(n))return;setState(() { claimedLevels.add(n); balance+=50+n*10; });}
 @override Widget build(BuildContext context)=>Scaffold(
  body:SafeArea(child:IndexedStack(index:tab,children:[home(),battlePass(),upgradePage(),duelPage(),missionPage(),inventoryPage(),profilePage()])),
  bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(i)=>setState(()=>tab=i),backgroundColor:const Color(0xFF171C27),indicatorColor:mint.withValues(alpha:.18),destinations:const[
   NavigationDestination(icon:Icon(Icons.inventory_2_outlined),selectedIcon:Icon(Icons.inventory_2),label:'Cases'),
   NavigationDestination(icon:Icon(Icons.military_tech_outlined),selectedIcon:Icon(Icons.military_tech),label:'Season'),
   NavigationDestination(icon:Icon(Icons.auto_fix_high_outlined),selectedIcon:Icon(Icons.auto_fix_high),label:'Upgrade'),
   NavigationDestination(icon:Icon(Icons.sports_mma_outlined),selectedIcon:Icon(Icons.sports_mma),label:'Duel'),
   NavigationDestination(icon:Icon(Icons.task_alt_outlined),selectedIcon:Icon(Icons.task_alt),label:'Missions'),
   NavigationDestination(icon:Icon(Icons.grid_view_outlined),selectedIcon:Icon(Icons.grid_view),label:'Inventory'),
   NavigationDestination(icon:Icon(Icons.person_outline),selectedIcon:Icon(Icons.person),label:'Profile'),
  ]),
 );
 Widget shell(String title,String subtitle,List<Widget> children)=>CustomScrollView(slivers:[
  SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.fromLTRB(18,18,18,8),child:Row(children:[
   Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontSize:25,fontWeight:FontWeight.w900)),const SizedBox(height:4),Text(subtitle,style:const TextStyle(color:muted,fontSize:12))])),
   Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:9),decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(14)),child:Row(children:[const Icon(Icons.account_balance_wallet,size:17,color:mint),const SizedBox(width:6),Text('${balance.toStringAsFixed(2)}',style:const TextStyle(fontWeight:FontWeight.bold))])),
  ]))),
  SliverPadding(padding:const EdgeInsets.fromLTRB(16,8,16,26),sliver:SliverList(delegate:SliverChildListDelegate(children))),
 ]);
 Widget box(Widget child,{EdgeInsets padding=const EdgeInsets.all(16)})=>Container(padding:padding,decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(20),border:Border.all(color:Colors.white.withValues(alpha:.06))),child:child);
 Widget heading(String text,{String? trailing})=>Padding(padding:const EdgeInsets.only(top:20,bottom:12),child:Row(children:[Expanded(child:Text(text.toUpperCase(),style:const TextStyle(fontSize:12,fontWeight:FontWeight.w900,letterSpacing:1.2))),if(trailing!=null)Text(trailing,style:const TextStyle(color:mint,fontWeight:FontWeight.bold,fontSize:11))]));
 Widget xpBar()=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
  Row(children:[Expanded(child:Text('LEVEL $level',style:const TextStyle(fontWeight:FontWeight.w900))),Text('$xp XP',style:const TextStyle(color:mint,fontWeight:FontWeight.bold,fontSize:11))]),
  const SizedBox(height:8),ClipRRect(borderRadius:BorderRadius.circular(20),child:LinearProgressIndicator(value:progress,minHeight:8,color:mint,backgroundColor:Colors.white10)),
  const SizedBox(height:6),Text('$levelXp / 1000 XP to next level',style:const TextStyle(color:muted,fontSize:11)),
 ]);
 Widget home()=>shell('CASE LAB','CS2 CASE SIMULATOR · SEASON 01',[
  box(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('YOUR NEXT\nBIG DROP?',style:TextStyle(fontSize:30,height:1.04,fontWeight:FontWeight.w900)),const SizedBox(height:9),const Text('Open cases, collect skins and climb the season track.',style:TextStyle(color:muted)),const SizedBox(height:16),xpBar()] ),padding:const EdgeInsets.all(20)),
  heading('Choose a case',trailing:'${caseList.length} CASES'),
  SizedBox(height:155,child:ListView.separated(scrollDirection:Axis.horizontal,itemCount:caseList.length,separatorBuilder:(_,__)=>const SizedBox(width:10),itemBuilder:(context,i){
   final c=caseList[i];return GestureDetector(onTap:opening?null:()=>setState(() { selected=c; lastDrop=null; status='Ready to open ${c.name}'; }),child:Container(width:155,padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:selected==c?c.color.withValues(alpha:.16):panel,borderRadius:BorderRadius.circular(18),border:Border.all(color:selected==c?c.color:Colors.white10)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(c.icon,size:29,color:c.color),const Spacer(),Text(c.name,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.bold)),Text(c.subtitle,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(color:muted,fontSize:10)),const SizedBox(height:5),Text('${c.price.toStringAsFixed(2)}',style:TextStyle(color:c.color,fontWeight:FontWeight.w900))])));
  })),
  const SizedBox(height:14),
  box(Column(children:[
   if(rollItems.isNotEmpty) openingRoller() else Container(width:90,height:90,decoration:BoxDecoration(shape:BoxShape.circle,color:(lastDrop?.color??selected.color).withValues(alpha:.12),border:Border.all(color:(lastDrop?.color??selected.color).withValues(alpha:.6),width:2)),child:Icon(opening?Icons.hourglass_top:(lastDrop?.icon??selected.icon),size:42,color:lastDrop?.color??selected.color)),
   const SizedBox(height:12),Text(lastDrop?.name??selected.name,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:20)),Text(lastDrop?.weapon??selected.subtitle,style:const TextStyle(color:muted,fontSize:12)),
   if(lastDrop!=null)Padding(padding:const EdgeInsets.only(top:6),child:Text('${lastDrop!.rarity} · ${lastDrop!.value.toStringAsFixed(2)}',style:TextStyle(color:lastDrop!.color,fontWeight:FontWeight.bold))),
   const SizedBox(height:8),Text(status,textAlign:TextAlign.center,style:const TextStyle(color:muted,fontSize:12)),const SizedBox(height:14),
   SizedBox(width:double.infinity,height:50,child:FilledButton.icon(onPressed:opening?null:openCase,icon:Icon(opening?Icons.hourglass_empty:Icons.lock_open),label:Text(opening?'OPENING…':'OPEN CASE · ${selected.price.toStringAsFixed(2)}'),style:FilledButton.styleFrom(backgroundColor:mint,foregroundColor:bg))),
   const SizedBox(height:7),const Text('Simulation only · virtual credits and items',style:TextStyle(color:muted,fontSize:10)),
  ])),
  heading('Season overview'),
  Row(children:[Expanded(child:box(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Icon(Icons.military_tech,color:mint),Text('LEVEL $level',style:const TextStyle(fontWeight:FontWeight.w900)),const Text('Battle Pass',style:TextStyle(color:muted,fontSize:11))]))),const SizedBox(width:10),Expanded(child:box(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Icon(Icons.task_alt,color:Color(0xFFB38CFF)),Text('${missions.where((m)=>m.claimed).length}/4',style:const TextStyle(fontWeight:FontWeight.w900)),const Text('Rewards claimed',style:TextStyle(color:muted,fontSize:11))]))) ]),
  OutlinedButton.icon(onPressed:()=>setState(()=>tab=1),icon:const Icon(Icons.arrow_forward),label:const Text('OPEN BATTLE PASS')),
 ]);
 Widget battlePass()=>shell('BATTLE PASS','SEASON 01 · OPERATION NIGHTFALL',[
  box(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   Row(children:[Container(width:52,height:52,decoration:BoxDecoration(color:mint.withValues(alpha:.14),borderRadius:BorderRadius.circular(15)),child:const Icon(Icons.military_tech,color:mint,size:31)),const SizedBox(width:12),const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('OPERATION NIGHTFALL',style:TextStyle(fontWeight:FontWeight.w900,fontSize:16)),Text('Free reward track',style:TextStyle(color:muted,fontSize:12))]))]),
   const SizedBox(height:18),xpBar(),const SizedBox(height:8),const Text('Earn XP from case openings and missions. Claim unlocked rewards below.',style:TextStyle(color:muted,fontSize:11)),
  ]),padding:const EdgeInsets.all(20)),
  heading('Reward track',trailing:'10 LEVELS'),
  ...List.generate(10,(i){
   final n=i+1;final unlocked=n<=level;final claimed=claimedLevels.contains(n);
   const names=['Credit bundle','Sticker capsule','Mil-Spec drop','Credit bundle','Case token','Classified drop','Rare charm','Credit bundle','Premium case','Knife token'];
   final icons=[Icons.monetization_on,Icons.stars,Icons.inventory_2,Icons.monetization_on,Icons.confirmation_number,Icons.auto_awesome,Icons.diamond,Icons.monetization_on,Icons.card_giftcard,Icons.workspace_premium];
   return Padding(padding:const EdgeInsets.only(bottom:9),child:box(Row(children:[
    Container(width:42,height:46,decoration:BoxDecoration(color:unlocked?mint.withValues(alpha:.14):Colors.white.withValues(alpha:.04),borderRadius:BorderRadius.circular(12)),child:Center(child:Text('$n',style:TextStyle(fontWeight:FontWeight.w900,color:unlocked?mint:muted)))),
    const SizedBox(width:11),Icon(icons[i],color:unlocked?mint:muted),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(names[i],style:const TextStyle(fontWeight:FontWeight.bold)),Text('Level $n reward',style:const TextStyle(color:muted,fontSize:11))])),
    if(claimed)const Icon(Icons.check_circle,color:mint) else if(unlocked)TextButton(onPressed:()=>claimLevel(n),child:const Text('CLAIM')) else const Icon(Icons.lock_outline,color:muted),
   ]),padding:const EdgeInsets.all(12)));
  }),
  box(const Text('Demo season: progress is stored locally in memory and resets when the app restarts. Cloud saves and a real-time season timer are not connected.',style:TextStyle(color:muted,fontSize:11))),
 ]);

 void doUpgrade(){
  final source=upgradeSource; final target=upgradeTarget;
  if(source==null||target==null||target.value<=source.skin.value)return;
  final chance=(0.95*source.skin.value/target.value).clamp(0.002,0.80);
  final won=random.nextDouble()<chance;
  setState((){
   upgradeAttempts++; inventory.remove(source);
   if(won){inventory.insert(0,OwnedSkin(target,++serial));upgradeWins++;upgradeHistory.insert(0,'WIN · ${source.skin.name} → ${target.name}');}
   else{upgradeHistory.insert(0,'MISS · ${source.skin.name} → ${target.name}');}
   upgradeSource=null;upgradeTarget=null;
   status=won?'Upgrade successful!':'Upgrade failed — stake lost.';
  });
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(won?'Upgrade success! You got ${target.name}.':'Upgrade failed. ${source.skin.name} was lost.')));
 }
 Widget upgradePage()=>shell('SKIN UPGRADE','RISK A SKIN FOR A CHANCE AT A BETTER ONE',[
  box(const Row(children:[Icon(Icons.auto_fix_high,color:mint,size:30),SizedBox(width:12),Expanded(child:Text('Choose a skin from your inventory and a more valuable target. The displayed chance is calculated before the attempt.',style:TextStyle(color:muted,fontSize:12)))])),
  heading('1 · Your item',trailing:'INVENTORY'),
  if(inventory.isEmpty)box(const Text('Your inventory is empty. Open a case first.',style:TextStyle(color:muted)))
  else box(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   DropdownButtonFormField<OwnedSkin>(value:inventory.contains(upgradeSource)?upgradeSource:null,isExpanded:true,decoration:const InputDecoration(labelText:'Skin to upgrade',border:OutlineInputBorder()),items:inventory.map((item)=>DropdownMenuItem(value:item,child:Text('${item.skin.name} · ${item.skin.value.toStringAsFixed(2)}',overflow:TextOverflow.ellipsis))).toList(),onChanged:(item)=>setState(() { upgradeSource=item; upgradeTarget=null; })),
   if(upgradeSource!=null)Padding(padding:const EdgeInsets.only(top:10),child:Text('Stake value: ${upgradeSource!.skin.value.toStringAsFixed(2)}',style:const TextStyle(color:mint,fontWeight:FontWeight.bold))),
  ])),
  heading('2 · Target skin',trailing:'HIGHER VALUE'),
  box(DropdownButtonFormField<Skin>(value:upgradeTarget, isExpanded:true,decoration:const InputDecoration(labelText:'Choose target',border:OutlineInputBorder()),items:skins.where((s)=>upgradeSource!=null&&s.value>upgradeSource!.skin.value).map((s)=>DropdownMenuItem(value:s,child:Text('${s.name} · ${s.value.toStringAsFixed(2)}',overflow:TextOverflow.ellipsis))).toList(),onChanged:upgradeSource==null?null:(s)=>setState(()=>upgradeTarget=s))),
  const SizedBox(height:12),
  if(upgradeSource!=null&&upgradeTarget!=null)box(Column(children:[
   const Text('SUCCESS CHANCE',style:TextStyle(color:muted,fontSize:11,fontWeight:FontWeight.bold,letterSpacing:1)),
   const SizedBox(height:6),Text('${(0.95*upgradeSource!.skin.value/upgradeTarget!.value*100).clamp(0.2,80).toStringAsFixed(2)}%',style:const TextStyle(color:mint,fontWeight:FontWeight.w900,fontSize:36)),
   Text('${(upgradeTarget!.value/upgradeSource!.skin.value).toStringAsFixed(2)}× multiplier',style:const TextStyle(color:muted)),
   const SizedBox(height:12),ClipRRect(borderRadius:BorderRadius.circular(20),child:LinearProgressIndicator(value:(0.95*upgradeSource!.skin.value/upgradeTarget!.value).clamp(0.002,0.80),minHeight:10,color:mint,backgroundColor:Colors.white10)),
   const SizedBox(height:10),SizedBox(width:double.infinity,height:48,child:FilledButton.icon(onPressed:doUpgrade,icon:const Icon(Icons.bolt),label:const Text('TRY UPGRADE'),style:FilledButton.styleFrom(backgroundColor:mint,foregroundColor:bg))),
   const SizedBox(height:7),const Text('Failure consumes the selected item. Success replaces it with the target. Demo items only.',textAlign:TextAlign.center,style:TextStyle(color:muted,fontSize:10)),
  ])),
  heading('Upgrade stats'),
  Row(children:[Expanded(child:stat(Icons.casino,'$upgradeAttempts','Attempts',mint)),const SizedBox(width:9),Expanded(child:stat(Icons.emoji_events,'$upgradeWins','Wins',const Color(0xFFFFC857)))]),
  if(upgradeHistory.isNotEmpty)...[
   heading('Recent attempts'),
   ...upgradeHistory.take(8).map((entry)=>Padding(padding:const EdgeInsets.only(bottom:7),child:box(Text(entry,style:TextStyle(fontWeight:FontWeight.bold,color:entry.startsWith('WIN')?mint:const Color(0xFFFF7B7B))),padding:const EdgeInsets.all(12)))),
  ],
 ]);


 Future<void> startDuel() async {
  if(duelRunning)return;
  final cost=selected.price*duelRounds;
  if(balance<cost){setState(()=>status='Not enough virtual credits for this duel.');return;}
  setState(() { duelRunning=true; balance-=cost; duelPlayerDrops=[]; duelBotDrops=[]; duelResult='Opening duel cases…'; });
  for(var i=0;i<duelRounds;i++){
   await Future<void>.delayed(const Duration(milliseconds:350));
   if(!mounted)return;
   final p=roll(),b=roll();
   setState(() { duelPlayerDrops=[...duelPlayerDrops,p]; duelBotDrops=[...duelBotDrops,b]; });
  }
  final playerValue=duelPlayerDrops.fold<double>(0,(sum,s)=>sum+s.value);
  final botValue=duelBotDrops.fold<double>(0,(sum,s)=>sum+s.value);
  setState(() {
   duelRunning=false; duelCount++;
   if(playerValue>botValue){duelWins++;balance+=cost*2;duelResult='YOU WIN · ${playerValue.toStringAsFixed(2)} vs ${botValue.toStringAsFixed(2)}';}
   else if(playerValue==botValue){balance+=cost;duelResult='DRAW · both totals are equal. Entry refunded.';}
   else{duelResult='BOT WINS · ${playerValue.toStringAsFixed(2)} vs ${botValue.toStringAsFixed(2)}';}
  });
 }
 Widget duelPage()=>shell('CASE DUELS','PLAY AGAINST THE BOT · VIRTUAL CREDITS ONLY',[
  box(const Row(children:[Icon(Icons.sports_mma,color:mint,size:30),SizedBox(width:12),Expanded(child:Text('Both sides open the same case for each round. The side with the highest total skin value wins.',style:TextStyle(color:muted,fontSize:12)))])),
  heading('Duel setup'),
  box(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   const Text('Case used for every round',style:TextStyle(fontWeight:FontWeight.bold)),
   const SizedBox(height:7),
   DropdownButtonFormField<CaseInfo>(value:selected,isExpanded:true,items:caseList.map((c)=>DropdownMenuItem(value:c,child:Text('${c.name} · ${c.price.toStringAsFixed(2)}'))).toList(),onChanged:duelRunning?null:(c)=>setState(()=>selected=c!)),
   const SizedBox(height:16),const Text('Number of rounds',style:TextStyle(fontWeight:FontWeight.bold)),
   const SizedBox(height:8),Wrap(spacing:8,children:[1,3,5].map((n)=>ChoiceChip(label:Text('$n rounds'),selected:duelRounds==n,onSelected:duelRunning?null:(v)=>setState(()=>duelRounds=n))).toList()),
   const SizedBox(height:12),Row(children:[const Expanded(child:Text('Entry cost',style:TextStyle(color:muted))),Text('${(selected.price*duelRounds).toStringAsFixed(2)}',style:const TextStyle(color:mint,fontWeight:FontWeight.w900))]),
   const SizedBox(height:12),SizedBox(width:double.infinity,height:48,child:FilledButton.icon(onPressed:duelRunning?null:startDuel,icon:Icon(duelRunning?Icons.hourglass_top:Icons.play_arrow),label:Text(duelRunning?'DUEL IN PROGRESS…':'START DUEL'),style:FilledButton.styleFrom(backgroundColor:mint,foregroundColor:bg))),
   const SizedBox(height:6),const Text('Winner receives twice the entry cost. A draw refunds the entry. Skins shown are simulated and are not added to inventory.',style:TextStyle(color:muted,fontSize:10)),
  ])),
  const SizedBox(height:12),box(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   Text(duelResult,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:15)),
   const SizedBox(height:12),
   Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Expanded(child:Column(children:[const Text('YOU',style:TextStyle(color:mint,fontWeight:FontWeight.w900)),const SizedBox(height:8),...duelPlayerDrops.asMap().entries.map((e)=>Padding(padding:const EdgeInsets.only(bottom:7),child:box(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Round ${e.key+1}',style:const TextStyle(color:muted,fontSize:10)),Text(e.value.name,style:const TextStyle(fontWeight:FontWeight.bold),maxLines:2,overflow:TextOverflow.ellipsis),Text('${e.value.value.toStringAsFixed(2)}',style:TextStyle(color:e.value.color,fontWeight:FontWeight.bold))]),padding:const EdgeInsets.all(9))))])),
    const SizedBox(width:8),
    Expanded(child:Column(children:[const Text('BOT',style:TextStyle(color:Color(0xFFFFC857),fontWeight:FontWeight.w900)),const SizedBox(height:8),...duelBotDrops.asMap().entries.map((e)=>Padding(padding:const EdgeInsets.only(bottom:7),child:box(Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Round ${e.key+1}',style:const TextStyle(color:muted,fontSize:10)),Text(e.value.name,style:const TextStyle(fontWeight:FontWeight.bold),maxLines:2,overflow:TextOverflow.ellipsis),Text('${e.value.value.toStringAsFixed(2)}',style:TextStyle(color:e.value.color,fontWeight:FontWeight.bold))]),padding:const EdgeInsets.all(9))))])),
   ]),
  ])),
  heading('Duel stats'),
  Row(children:[Expanded(child:stat(Icons.sports_mma,'$duelCount','Duels played',mint)),const SizedBox(width:9),Expanded(child:stat(Icons.emoji_events,'$duelWins','Wins',const Color(0xFFFFC857)))]),
 ]);

 Widget missionPage()=>shell('MISSIONS','DAILY CHALLENGES · BONUS CREDITS',[
  box(const Row(children:[Icon(Icons.task_alt,color:Color(0xFFB38CFF),size:30),SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Mission board',style:TextStyle(fontWeight:FontWeight.w900,fontSize:16)),Text('Complete objectives for rewards and XP.',style:TextStyle(color:muted,fontSize:11))]))])),
  heading('Your missions',trailing:'${missions.where((m)=>m.complete).length}/4 COMPLETE'),
  ...missions.map((m)=>Padding(padding:const EdgeInsets.only(bottom:10),child:box(Column(children:[
   Row(children:[Container(width:40,height:40,decoration:BoxDecoration(color:mint.withValues(alpha:.12),borderRadius:BorderRadius.circular(12)),child:Icon(m.icon,color:mint)),const SizedBox(width:11),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(m.title,style:const TextStyle(fontWeight:FontWeight.bold)),Text(m.desc,style:const TextStyle(color:muted,fontSize:11))])),Text('+${m.reward}',style:const TextStyle(color:mint,fontWeight:FontWeight.w900))]),
   const SizedBox(height:12),Row(children:[Expanded(child:ClipRRect(borderRadius:BorderRadius.circular(20),child:LinearProgressIndicator(value:(m.progress/m.goal).clamp(0,1),minHeight:6,color:m.complete?mint:const Color(0xFFB38CFF),backgroundColor:Colors.white10))),const SizedBox(width:10),Text('${min(m.progress,m.goal)}/${m.goal}',style:const TextStyle(color:muted,fontSize:11))]),
   if(m.complete)Align(alignment:Alignment.centerRight,child:TextButton.icon(onPressed:m.claimed?null:()=>claimMission(m),icon:Icon(m.claimed?Icons.check_circle:Icons.redeem),label:Text(m.claimed?'CLAIMED':'CLAIM REWARD'))),
  ])))),
  box(const Text('Daily reset is not connected yet; mission progress is a local demo.',style:TextStyle(color:muted,fontSize:11))),
 ]);
 Widget inventoryPage()=>shell('INVENTORY','${inventory.length} ITEMS · SELL SKINS FOR CREDITS',[
  if(inventory.isEmpty)box(const Column(children:[Icon(Icons.inventory_2_outlined,size:45,color:muted),SizedBox(height:9),Text('Your inventory is empty',style:TextStyle(fontWeight:FontWeight.bold)),SizedBox(height:4),Text('Open a case to collect your first skin.',style:TextStyle(color:muted,fontSize:12))]))
  else ...[
   box(Row(children:[const Expanded(child:Text('COLLECTION VALUE',style:TextStyle(color:muted,fontSize:11,fontWeight:FontWeight.bold))),Text('${inventory.fold<double>(0,(sum,item)=>sum+item.skin.value).toStringAsFixed(2)}',style:const TextStyle(color:mint,fontWeight:FontWeight.w900,fontSize:18))])),
   const SizedBox(height:10),
   ...inventory.map((item)=>Padding(padding:const EdgeInsets.only(bottom:9),child:box(Row(children:[Container(width:46,height:46,decoration:BoxDecoration(color:item.skin.color.withValues(alpha:.12),borderRadius:BorderRadius.circular(12)),child:Icon(item.skin.icon,color:item.skin.color,size:26)),const SizedBox(width:11),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(item.skin.name,style:const TextStyle(fontWeight:FontWeight.bold)),Text('${item.skin.weapon} · ${item.skin.rarity}',style:const TextStyle(color:muted,fontSize:10)),Text('${item.skin.value.toStringAsFixed(2)}',style:TextStyle(color:item.skin.color,fontWeight:FontWeight.bold))])),TextButton(onPressed:()=>sell(item),child:const Text('SELL'))]),padding:const EdgeInsets.all(12)))),
  ],
 ]);
 Widget stat(IconData icon,String value,String label,Color color)=>box(Row(children:[Icon(icon,color:color,size:24),const SizedBox(width:9),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(value,style:const TextStyle(fontWeight:FontWeight.w900)),Text(label,style:const TextStyle(color:muted,fontSize:10))]))]),padding:const EdgeInsets.all(13));
 Widget profilePage()=>shell('PLAYER PROFILE','YOUR CAREER SUMMARY',[
  box(Column(children:[Container(width:76,height:76,decoration:BoxDecoration(shape:BoxShape.circle,color:mint.withValues(alpha:.13),border:Border.all(color:mint.withValues(alpha:.6),width:2)),child:const Icon(Icons.person,color:mint,size:40)),const SizedBox(height:12),const Text('CASE COMMANDER',style:TextStyle(fontWeight:FontWeight.w900,fontSize:20)),const Text('Season 01 · Free player',style:TextStyle(color:muted,fontSize:12)),const SizedBox(height:16),xpBar()] ),padding:const EdgeInsets.all(20)),
  heading('Career stats'),
  Row(children:[Expanded(child:stat(Icons.lock_open,'$opened','Cases opened',mint)),const SizedBox(width:9),Expanded(child:stat(Icons.grid_view,'${inventory.length}','Skins owned',const Color(0xFFB38CFF)))]),
  const SizedBox(height:9),Row(children:[Expanded(child:stat(Icons.task_alt,'${missions.where((m)=>m.claimed).length}','Missions claimed',const Color(0xFFFFC857))),const SizedBox(width:9),Expanded(child:stat(Icons.sell,'$soldCredits','Credits from sales',const Color(0xFF43A6E8)))]),
  heading('About'),
  box(const Text('Fan-made CS2-style simulator for entertainment. All balances and items are virtual. No real-money trading, cloud saves or Valve affiliation.',style:TextStyle(color:muted,fontSize:11))),
 ]);
}
