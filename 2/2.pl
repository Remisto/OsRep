sub help{
	print "\tYou must declare output file and at least one input file.\n";
	print "\tFor example: output.txt first.txt second.txt third.txt";
	exit;
}

if($line = shift){
	if(-w $line)#-w - доступен ли файл для записи.
	{
		$output=$line;
	} else {print "\tFile ".$line." not available for write."; exit; }
} else {
	help();
}

$i=0;
@numbers[0]=0;
while($line = shift)
{
	if((-r $line))#-r - доступен ли файл для чтения. -s - размер файла.
	{
		eval{
			open(FILE, $line) or die "\tCan't open ".$line;
			$str="";
			while(!eof(FILE))
			{
				read FILE, $x, 1 or die "\tCant'r read symbol in ".$line;
				if($x!~/\s/){$str.=$x;}
				else{
					if($str=~/^\d+$/){ $numbers[$i] = $str or die "\tCan't add new element to array."; $i++; }
					if($i<0){ print "\tArray overflow. We apologize."; exit;}
					$str="";
				}
			}
			close FILE;
		}
		warn $@ if $@;
	} else {print "\tFile ".$line." not available for read or file size is too much."; exit; }
}

$,=" ";

@sort_numbers = sort {$a <=> $b} @numbers;

open(OUT,'>', $output) or die "\tCan't open ".$output;
print OUT @sort_numbers or die "\tCan't write symbol into ".$output;
#$i=0;
#while($i<$#sort_numbers)
#{
#	print OUT $sort_numbers[$i];
#	print OUT " ";
#	$i++;
#}
close OUT;