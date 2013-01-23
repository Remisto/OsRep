#перерезать проводки можно из консоли
print "If u want cut cable then enter cable number and press Enter\nRepeat action to cut another cable\nThen enter 's' and press Enter to start application.\n";
print "\nU can cut cables: pusk[1], zapp[2], vzap1[3], zam1[4], zam2[5], op[6], chist[7, pereh[8], vib[9]\n\n";
for($i=1; $i<=9; $i++){
	$broken[$i]=0;
}
while (<>) {
	$_ =~ s/\s+//g;
	if($_ eq "s"){ 
		close ARGV; 
	}else{
		print "Now cable '".$_."' is broken.\n";
		$broken[$_] = 1;
	}
}
$IP=0;
#Инициализируем оп-оп
open(RAM, 'ram.txt');
$_="";
$i=0;
$f=0;
our @ram;
while(!eof(RAM))
{
	read RAM, $x, 1;
	if($f==0){$ram[$i]=$x;$f++;}else{$ram[$i].=$x;$f=0; $i++;}
}
close RAM;

sub RegCom
{
	@com = @_;
	$cop=$com[0];
	$A=$com[1];
	return $cop, $A;
}

sub DecCom
{
	$cop = shift @_;
	$pri = shift @_;
	$f = shift @_;
	$I=0;
	#print "\n".$pri."\n";
	@p=split(//,$pri);
	#print "\n".$p[0]."\n";
	SWITCH: 
	{
		if( $cop eq "00" ){ $pereh=0; $Op=0; $P=0; last SWITCH; }
		if( $cop eq "01" ){ $pereh=0; $Op=1; $P=1; $I=0; last SWITCH; }
		if( $cop eq "15" ){ $pereh=0; $Op=1; $P=1; $I=1; last SWITCH; }
		if( $cop eq "02" ){ $pereh=0; $Op=0; $P=2; last SWITCH; }
		if( $cop eq "21" ){ $pereh=0; $Op=2; $P=1; $I=0; last SWITCH; }
		if( $cop eq "25" ){ $pereh=0; $Op=2; $P=1; $I=1; last SWITCH; }
		if( $cop eq "31" ){ $pereh=0; $Op=3; $P=1; $I=0; last SWITCH; }
		if( $cop eq "FE" ){ $pereh=1; $Op="F"; $P=4; last SWITCH; }
		if( $cop eq "F0" ){ if($p[0]==0){$pereh=1;}else{$pereh=0;} $Op="F"; $P=4; last SWITCH; }
		if( $cop eq "F1" ){ if($p[1]==1){$pereh=1;}else{$pereh=0;}$pereh=0; $Op="F"; $P=4; last SWITCH; }
		if( $cop eq "F4" ){ if($f==0){$pereh=1;}else{$pereh=0;} $pereh=0; $Op="F"; $P=4; last SWITCH; }
		if( $cop eq "F5" ){ if($f==1){$pereh=1;}else{$pereh=0;} $pereh=1; $Op="F"; $P=4; last SWITCH; }
		if( $cop eq "FF" ){ $pereh=0; $Op="F"; $P=4; last SWITCH; }
	}
	if($cop eq "FF"){$pusk=0;}else{$pusk=1;}
	if($P==3){$vzap1=1;}else{$vzap1=0;}
	if($P==1){$zam1=1;}else{$zam1=0;}
	if($P!=3){$zam2=1;}else{$zam2=0;}
	if(!($P==2 || $P==3)){$chist=1;}else{$chist=0;}
	$vib=$I;
	if($P==0){$zapp=1;}else{$zapp=0;}
		#Дальше проверим - обрезаны ли проводки. Где обрезаны, поставим нули.
		if($broken[1]==1){ $pusk=0; }
		if($broken[2]==1){ $zapp=0; }
		if($broken[3]==1){ $vzap1=0; }
		if($broken[4]==1){ $zam1=0; }
		if($broken[5]==1){ $zam2=0; }
		if($broken[6]==1){ $Op=0; }
		if($broken[7]==1){ $chist=0; }
		if($broken[8]==1){ $pereh=0; }
		if($broken[9]==1){ $vib=0; }
	return $pusk, $vzap1, $zam1, $zam2, $chist, $Op, $vib, $zapp, $pereh;
}

sub Summator
{
	$a=shift @_;
	$b=shift @_;
	return $a+$b;
}

sub Multiplexor
{
	local $attribute=shift @_;
	$a = shift @_;
	$b = shift @_;
	if(defined($_[0])){$c = shift @_;}else{$c=0;}
	if($attribute==0){return $a;}
	if($attribute==1){return $b;}
	if($attribute==2){return $c;}
	return 0;
}

sub ALU
{
	$a = shift @_;
	$b = shift @_;
	$o = shift @_;
	$rez=0;
	$p="00";
	if($o==0){ $rez=$b; }
	if($o==1){ $rez=$a; }
	if($o==2){ $rez=$a+$b; }
	if($o==3){ $rez=$b-$a; }
	if($rez==0){ $p="0"; }else{ $p="1"; }
	if($rez>0){ $p.="1"; }else{ $p.="0"; }
	return $rez, $p;
}

sub writeram
{
	#open(RAM, '>ram.txt');
	#print RAM @ram;
	#close RAM;
}

sub toHex
{
	$a = shift @_;
	$hexval = sprintf("%x", $a);
	return $hexval
}

sub toDec
{
	$a = shift @_;
	$decval = hex($a);
	return $decval;
}

#инициализируем какие-нибудь регистры
$i=1;
while($i<$#ram)
{
	$ram[$i]=toDec($ram[$i]);
	$i+=2;
}

$IR=0;
$sum=0;
$prznk="00";
$sum=0;
$flag=0;
$vnesh=0;
$qwe=0;
($cop, $A) = RegCom($ram[$IP],$ram[$IP+1]);
@deccomregs=DecCom($cop, $prznk, $flag);
print $IP.": ".$cop." ".$A.". pereh:".$deccomregs[8];
while($deccomregs[0]!=0)
{
	print ", IR: ".$IR;
	$IA = Summator($A, $IR);
	$Sp=$ram[$IA];
	$MultiVibResult=Multiplexor($deccomregs[6], $Sp, $IA, $vnesh);
	($REZ1, $pr)=ALU($MultiVibResult, $sum, $deccomregs[5]);
	if($deccomregs[2]==1)
	{
		$prznk=$pr;
		$sum=$REZ1;
	}
	print ", prznk: ".$prznk;
	print ", chist: ".$deccomregs[4];
	print ", REZ1: ".$REZ1;
	if($deccomregs[3]==1){$IR=Multiplexor($deccomregs[4], $REZ1, 0);}
	if($deccomregs[7]==1){$ram[$IA]=$REZ1; writeram();}
	if($deccomregs[1]==1){$flag=1; $vnesh=$REZ1;}
	$IP+=2;
	$IP=Multiplexor($deccomregs[8], $IP, $IA);
	print ", next IP: ".$IP."\n";
	($cop, $A) = RegCom($ram[$IP],$ram[$IP+1]);
	@deccomregs=DecCom($cop, $prznk, $flag);
	print $IP.": ".$cop." ".$A.". pereh:".$deccomregs[8];
	#if($qwe==5){exit;}else{$qwe++;}
}