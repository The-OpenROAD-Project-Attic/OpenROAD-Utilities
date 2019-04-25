#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname(dirname abs_path $0) . '/perl';

#require LIB::SPICEGEN;
#use LIB::SPICEGEN qw/ spice_gen /;

# Parse ARGV
my ($field, $filename, $clean_summary) = @ARGV;

if (not defined $field)
{
	die "Need field or filename\n";
}
else
{
	print "\n================================\n";
	print "Reading $filename ...\n";
	print "================================\n";
}

#my $filename = './perl/spice_correlation_top.pl.cfg';
open(my $fh, '<', $filename)
	or die "Can't open < $filename: $!";

# Folder definition
my $lib_folder = './work/lib/';
my $sdc_folder = './work/sdc/';
my $gen_verilog_folder = './work/gen_verilog/';
my $gen_spef_folder = './work/gen_spef/';
my $sta_folder = './work/sta/';
my $tempus_folder = './work/tempus/';
my $tempus_result_dir = './work/tempus_result/';
my $tempus_result_folder = './work/tempus_path_result/';
my $sta_result_folder = './work/sta_path_result/';
my $pin_check_folder = './work/pin_check/';

# Parameters for input parameters
my $mode = '';
# CC Coupling Cap Mode
# ST Single stage Mode
my $target_cellname = '';
my $lib_filename = '';
my $cdl_spice_netlist = '';
my $model = '';
my $result_dir = '';
my $spice_dir = '';
my $tempus_spice_dir = './work/tempus_spice_netlist/';
my $module_input = '';
my $module_output = '';
my $in_net = '';
my $out_net='';
my $power_net = '';
my $ground_net = '';
my @supply_vol = '';
my @input_slew = '';
my @cload = '';
my $input_pin_list_file='';
my $fanout_num = 1;
my $corner = '';
my $path_wirelength = 1;
my $unitR = 1;
my $unitC = 1;
while (my $row = <$fh>)
{
	chomp $row;
	my ($field, $content) = split(/=/, $row);
	$field =~ s/^\s+|\s+$//g;
	$content =~ s/^\s+|\s+$//g;
	if($field eq 'CELL_NAME')
	{
		print("STD CELL NAME: $content\n");
		$target_cellname = $content;
	}
	elsif($field eq 'LIB_FILE')
	{
		print("LIB FILE: $content\n");
		$lib_filename = $content;
	}
	elsif($field eq 'SPICEMODEL_FILE') { 
		print("MODEL: $content\n");
		$model = $content; 
	}
        elsif($field eq 'SPICE_NETLIST') {
		print("NETLIST: $content\n");
		$cdl_spice_netlist = $content;
	}
	elsif($field eq 'RESULT_DIR') {
		print("RESULT DIR: $content\n");
		$result_dir = $content;
	}
	elsif($field eq 'INPUT_PIN') {
		print("INPUT PIN: $content\n");
		$in_net = $content;
	}
	elsif($field eq 'OUTPUT_PIN') {
		print("OUTPUT PIN: $content\n");
		$out_net = $content;
	}
	elsif($field eq 'POWER_PIN') {
		print("POWER PIN: $content\n");
		$power_net = $content;
	}
	elsif($field eq 'GROUND_PIN'){
		print("GROUND PIN: $content\n");
		$ground_net = $content;
	}
	elsif($field eq 'INPUT_SLEW') {
		print("INPUT SLEW RANGE: $content\n");
		@input_slew = split(/ /, $content);
	}
	elsif($field eq 'CLOAD') {
		print("CLOAD RANGE: $content\n");
		@cload = split(/ /, $content);
	}
	elsif($field eq 'INPUT_PIN_LIST_FILE') {
		print("INPUT PIN LIST FILE: $content\n");
		$input_pin_list_file = $content;		
	}
	elsif($field eq 'FANOUT') {
		print("FANOUT Number: $content\n");
		$fanout_num = $content;
	}
	elsif($field eq 'SPICE_DIR') {
		print("SPICE DIR: $content\n");
		$spice_dir = $content;
	}
	elsif($field eq 'CORNER') {
		print("CORNER: $content\n");
		$corner = $content;
	}
	elsif($field eq 'PATH_WIRE_LENGTH')
	{
		print("PATH WIRE LENGTH: $content\n");
		$path_wirelength = $content;
	}
	elsif($field eq 'unitR')
	{
		print("UNIT R: $content\n");
		$unitR = $content;
	}	
	elsif($field eq 'unitC')
	{
		print("UNIT C: $content\n");
		$unitC = $content;
	}

}
print "\n================================\n";
print "Parsing Configuration File Done!\n";
print "================================\n";
# Generating new verilog file and lib cfg file

print "\n================================\n";
print "Generating Verilog and OpenSTA tcl script...\n";
print "================================\n";
my $verilog = "top";
my $verilog_ori = $verilog;
print "\nreading liberty $lib_filename...\n";
my ($time_unit, $cap_unit, $Input_slew_rate_add, $slew_lower_threshold_pct_fall, $slew_lower_threshold_pct_rise, 
	$slew_upper_threshold_pct_fall, $slew_upper_threshold_pct_rise, $cell_input_pins_add, $cell_output_pins_add ) = read_slew_rate_table_from_lib($lib_filename, $target_cellname);
my @cell_input_pins = @{$cell_input_pins_add};
my @cell_output_pins = @{$cell_output_pins_add};
print "time unit: $time_unit\ncap unit: $cap_unit\n";
print Dumper(\@cell_input_pins);
print Dumper(\@cell_output_pins);
my @Input_slew_rate_matrix = @{$Input_slew_rate_add};
my @Input_Pin_Assign = @{get_input_pin_info($input_pin_list_file)};
if($clean_summary eq "-clrsum")
{
	`rm ./Gen_summary.txt`;
}

for (my $s_loc = $input_slew[0]; $s_loc <= $input_slew[1]; $s_loc = $s_loc+1)
{
	my $s = $Input_slew_rate_matrix[$s_loc];
	my $c = 0;
	for(my $c = $cload[0]; $c <= $cload[1]; $c = $c+$cload[2])
	{
		{
			# No need for Tempus now, but leave it.
			my $gen_verilog_name = $gen_verilog_folder.$target_cellname."_slew$s"."_load$c"."\.v";
			my $gen_result_file_name = $result_dir;
			my $gen_tempus_result_file_name = $tempus_result_dir;
			print("Generating Verilog File ", $gen_verilog_folder, "\n");
			my $parasitic_connects_add = gen_verilog_file($gen_verilog_name, $target_cellname, $fanout_num, $cell_input_pins_add, $cell_output_pins_add, \@Input_Pin_Assign);			 
	
			my $gen_spef_name = $gen_spef_folder.$target_cellname."_slew$s"."_load$c"."\.spef";
			gen_spef_file($gen_spef_name, $parasitic_connects_add, $path_wirelength, $unitR, $unitC, $c, $cap_unit, $time_unit);
			my $gen_opensta_tclname = $sta_folder."run_os_".$target_cellname."_slew$s"."_load$c"."\.tcl";
			my $gen_tempus_tclname = $tempus_folder."run_os_".$target_cellname."_slew$s"."_load$c"."\.tcl";
			my $opensta_log = $sta_folder."run_os_".$target_cellname."_slew$s"."_load$c"."\.log";
			my $opensta_timing_path = $sta_result_folder."opensta_".$target_cellname."_slew$s"."_load$c"."\.log";
			my $tempus_timing_path = $tempus_result_folder."tempus_".$target_cellname."_slew$s"."_load$c"."\.log";
			my $sdc_filename = $sdc_folder.$target_cellname."_slew$s"."_load$c"."\.sdc";
			
			# generate opensta and sdc file
			gen_opensta_tcl($gen_opensta_tclname, $lib_filename, $gen_verilog_name, $sdc_filename, $gen_spef_name, $corner, $opensta_log, $opensta_timing_path );
			#gen_tempus_tcl($gen_tempus_tclname, $lib_filename, $gen_verilog_name, $sdc_filename, $gen_spef_name, $corner, $opensta_log, $tempus_timing_path );
			gen_sdc_file($sdc_filename, $s);
			system("sta -f $gen_opensta_tclname");
			#system("tempus -file $gen_tempus_tclname -no_gui");
			my $dumped_spice_name = $spice_dir."\/".$target_cellname."_slew$s"."_load$c"."\.sp";
			`mv $spice_dir/path_1.sp $dumped_spice_name`;
			system("hspice -i $dumped_spice_name -o $gen_result_file_name");
			`mv $spice_dir/path_1.subckt $spice_dir\/$target_cellname."_slew$s"."_load$c"."\.subckt`;
			
			# Tempus
			#my $dumped_tempus_spice_name = $tempus_spice_dir."\/".$target_cellname."_slew$s"."_load$c"."\.sp";
			#`mv $tempus_spice_dir/path_1_setup.sp $dumped_tempus_spice_name`;
			#system("hspice -i $dumped_tempus_spice_name -o $gen_tempus_result_file_name");
			#`mv $tempus_spice_dir/path_1_setup.subckt $tempus_spice_dir\/$target_cellname."_slew$s"."_load$c"."\.subckt`;	

			my $mt0_file = $gen_result_file_name."\/".$target_cellname."_slew$s"."_load$c"."\.mt0";
			#my $tempus_mt0_file = $gen_tempus_result_file_name."\/".$target_cellname."_slew$s"."_load$c"."\.mt0";
			compare_sta2spice_measure($opensta_timing_path, $mt0_file, "OpenSTA_Summary_Report.txt", 0);
			#compare_sta2spice_measure($tempus_timing_path, $tempus_mt0_file, "Tempus_Summary_Report.txt", 1);
			
		}
	}
}


print "Done\n";


#===============================================
# sub function
#===============================================

sub gen_verilog_file 
{
	my ($verilog_file, $cell, $fanout_num, $input_pins_add, $output_pins_add, $Input_pin_assign_add ) = @_;
	my @input_pins = @{$input_pins_add};
	my @output_pins = @{$output_pins_add};
	my @Input_Pin_Assign = @{$Input_pin_assign_add};
	my %parasitic_net_connect;
        open (my $fh, ">", $verilog_file)
		 or die " $verilog_file: $!"; 
	
	my $gatename = 1;
	my $out_wire = 1;
	my $num_stage = 2;
	my $cur_stage = 1;
	
	print $fh "module top (\n";
	print $fh "\tinput IN,\n";
	print $fh "\tinput CLK,\n";
	print $fh "\toutput OUT\n";
	print $fh ")\;\n\n";
	#print $fh "wire w1\n";
    
	print $fh "$cell U$gatename (";
	# Pin and Assignment finding
	# First stage
	for(my $p=0; $p<@input_pins; $p = $p+1)
	{
		if($input_pins[$p] eq $in_net)
		{
			print $fh ".$input_pins[$p]\(IN\), ";
		}
		else
		{
			for(my $i=0; $i<@Input_Pin_Assign; $i = $i+2)
			{
				if($Input_Pin_Assign[$i] eq $input_pins[$p])
				{
					print $fh ".$input_pins[$p]\(1'b$Input_Pin_Assign[$i+1]\), ";
				}
			}
		}
	}
	print $fh ".$output_pins[0]\(Out$out_wire\)\)\;\n";
        my $pre_fanout_net = "Out$out_wire";	
	$parasitic_net_connect{$pre_fanout_net}{'input'} = "U$gatename\:$output_pins[0]";
	$cur_stage = $cur_stage + 1;
	while ($cur_stage <= $num_stage)
	{

		for(my $f=0; $f < $fanout_num; $f=$f+1)
		{
			$gatename = $gatename+1;
			if($cur_stage < $num_stage or $f != 0)
			{
				$out_wire = $out_wire+1;
			}
			print $fh "$cell U$gatename (";
			for(my $p=0; $p<@input_pins; $p = $p+1)
			{
				if($input_pins[$p] eq $in_net)
				{
					print $fh ".$input_pins[$p]\($pre_fanout_net\), ";
					# record in the hash
					$parasitic_net_connect{$pre_fanout_net}{'output'}[$f] = "U$gatename\:$input_pins[$p]";
				}
				else
				{
					for(my $i=0; $i<@Input_Pin_Assign; $i = $i+2)
					{
						if($Input_Pin_Assign[$i] eq $input_pins[$p])
						{
							print $fh ".$input_pins[$p]\(1'b$Input_Pin_Assign[$i+1]\), ";
						}

					}
				}
			}
			if($cur_stage == $num_stage and $f == 0)
			{
				print $fh ".$output_pins[0]\(OUT\)\)\;\n";
				$parasitic_net_connect{OUT}{'input'} = "U$gatename\:$output_pins[0]";
				$parasitic_net_connect{OUT}{'output'}[0] = "OUT";
			}
			else
			{
				print $fh ".$output_pins[0]\(Out$out_wire\)\)\;\n";	
			}	
	
		}
		$cur_stage = $cur_stage+1;
	}
	
	print $fh "\nendmodule";
	close $fh;
	print Dumper \%parasitic_net_connect;
	return \%parasitic_net_connect;
}

sub gen_spef_file
{
	my ($spef_file, $parasitics_connect_add, $path_wirelength, $unitR, $unitC, $Cload, $cap_unit, $time_unit) = @_;
	
	my %parasitic_connects = %{$parasitics_connect_add};
	print Dumper \%parasitic_connects;
	open (my $fh, ">", $spef_file)
		 or die " $spef_file: $!";
	print $fh "\*SPEF \"1481-1998\"\n";
	print $fh "\*DESIGN \"top\"\n";
	print $fh "\*DATE \"Mon Jul 15 12:05:09 2013\"\n";
	print $fh "\*VENDOR \"Synopsys, Inc.\"\n";
	print $fh "\*PROGRAM \"icc_shell\"\n";
	print $fh "\*VERSION \"G-2012.06-ICC-SP3\"\n";
	print $fh "\*DESIGN_FLOW \"PIN_CAP NONE\"\n";
	print $fh "\*DIVIDER \/\n";
	print $fh "\*DELIMITER \:\n";
	print $fh "\*BUS_DELIMITER \[ \]\n";
	my $t_u = uc $time_unit;
	my $c_u = uc $cap_unit;	
	print $fh "\*T_UNIT 1 $t_u"."S\n";
	print $fh "\*C_UNIT 1 $c_u"."F\n";
	print $fh "\*R_UNIT 1 OHM\n";
	print $fh "\*L_UNIT 1 HENRY\n";

        my $totalR = $unitR*$path_wirelength;
	my $total_net_C = $unitC*$path_wirelength;
	my $totalC = $unitC*$path_wirelength;
	
	foreach my $net (keys %parasitic_connects)
	{
		if ($net eq "OUT")
		{	
			$totalC = $totalC + $Cload;
		}
		print $fh "\n\n\*D_NET $net $totalC\n";
		print $fh "\*CONN\n";
		my $type = "I";
		if($parasitic_connects{$net}{'input'} =~ m/^U*/)
		{
			$type = "I";
		}
		else
		{
			$type = "P";
		}
		print $fh "\*$type $parasitic_connects{$net}{'input'} I\n";
		my $output_add = $parasitic_connects{$net}{'output'};
		for my $output (@{$output_add})
		{
			if($output =~ m/^U\d*+/)
			{
				print "output: $output\n";
				$type = "I";
			}
			else
			{
				$type = "P";
			}
			print $fh "\*$type $output O\n";
		}
		print $fh "\*CAP\n";
		# T model
		my $cap = $total_net_C/2;
		print $fh "1 $net:0 $cap\n";
		print $fh "2 $net:1 $cap\n";
		if ($net eq "OUT" and $Cload > 0)
		{
			# Attach C load
			print $fh "3 $net $Cload\n";
		}
		print $fh "\*RES\n";
		my $res_4 = $totalR/4;
		my $res_2 = $totalR/2;
		print $fh "1 $parasitic_connects{$net}{'input'} $net:0 $res_4\n";
		print $fh "2 $net:0 $net:1 $res_2\n";
		my $res_num = 3;
		for my $output (@{$output_add})
		{
			print $fh "$res_num $net:1 $output $res_4\n";
			$res_num = $res_num + 1;
		}
		print $fh "\*END\n";
	}
	close $fh;
}

sub gen_verilog_file_FF 
{
	my ($verilog_file, $cell, $fanout_num, $input_pins_add, $output_pins_add, $Input_pin_assign_add, $FF_cell, $FF_input_pins_add, $FF_output_pins_add ) = @_;
	my @input_pins = @{$input_pins_add};
	my @output_pins = @{$output_pins_add};
	my @FF_input_pins = @{$FF_input_pins_add};
	my @FF_output_pins = @{$FF_output_pins_add};

	my @Input_Pin_Assign = @{$Input_pin_assign_add};
        open (my $fh, ">", $verilog_file)
		 or die " $verilog_file: $!"; 
	
	my $gatename = 1;
	my $flipflopname = 1;
	my $out_wire = 1;
	my $num_stage = 2;
	my $cur_stage = 1;
	
	print $fh "module top (\n";
	print $fh "\tinput IN\n";
	print $fh "\tinput CLK\n";
	print $fh "\toutput OUT\n";
	print $fh ")\;\n\n";
	#print $fh "wire w1\n";
    
	#print $fh "$FF_cell D$flipflopname (";
	

	print $fh "$cell U$gatename (";
	# Pin and Assignment finding
	# First stage
	for(my $p=0; $p<@input_pins; $p = $p+1)
	{
		if($input_pins[$p] eq $in_net)
		{
			print $fh ".$input_pins[$p]\(IN\), ";
		}
		else
		{
			for(my $i=0; $i<@Input_Pin_Assign; $i = $i+2)
			{
				if($Input_Pin_Assign[$i] eq $input_pins[$p])
				{
					print $fh ".$input_pins[$p]\($Input_Pin_Assign[$i+1]\), ";
				}
			}
		}
	}
	print $fh ".$output_pins[0]\(Out$out_wire\)\)\;\n";
	my $pre_fanout_net = "Out$out_wire";
	$cur_stage = $cur_stage + 1;
	while ($cur_stage <= $num_stage)
	{

		for(my $f=0; $f < $fanout_num; $f=$f+1)
		{
			$gatename = $gatename+1;
			if($cur_stage < $num_stage or $f != 0)
			{
				$out_wire = $out_wire+1;
			}
			print $fh "$cell U$gatename (";
			for(my $p=0; $p<@input_pins; $p = $p+1)
			{
				if($input_pins[$p] eq $in_net)
				{
					print $fh ".$input_pins[$p]\($pre_fanout_net\)";
				}
				else
				{
					for(my $i=0; $i<@Input_Pin_Assign; $i = $i+2)
					{
						if($Input_Pin_Assign[$i] eq $input_pins[$p])
						{
							print $fh ".$input_pins[$p]\($Input_Pin_Assign[$i+1]\), ";
						}

					}
				}
			}
			if($cur_stage == $num_stage and $f == 0)
			{
				print $fh ".$output_pins[0]\(OUT\)\)\;\n";
			}
			else
			{
				print $fh ".$output_pins[0]\(Out$out_wire\)\)\;\n";			
			}	
	
		}
		$cur_stage = $cur_stage+1;
	}
	
	print $fh "\nendmodule";
	close $fh;
	return;
}


sub gen_opensta_tcl 
{
	my ($tcl, $lib, $verilog, $sdc, $spef, $corner, $log_file, $path_report) = @_;
	open (my $fh, ">", $tcl)
		 or die " $tcl: $!"; 

	## scripts for OpenSTA
	print $fh "set log_file \"$log_file\"\n";
	print $fh "set design top\n";

	print $fh "set libdir \"\.\/\"\n";

	print $fh "set lib_tt \"$lib \"\n";

	print $fh "set lib_tt_mem \"\"\n";

	print $fh "log_begin \"$log_file\"\n";

	print $fh "set list_lib \"\$lib_tt \$lib_tt_mem\"\n";

	print $fh "# Target library\n";
	print $fh "set link_library \$list_lib\n";
	print $fh "set target_library \$list_lib\n\n";
	print $fh "set netlist $verilog\n";
	print $fh "set sdc $sdc\n";
	print $fh "set spef $spef\n\n";
	print $fh "define_corners $corner\n";

	print $fh "foreach lib \$list_lib {\nread_liberty -corner $corner \$lib\n}\n";

	print $fh "read_verilog \$netlist\n";

	print $fh "link_design \$design\n";

	print $fh "read_parasitics -keep_capacitive_coupling -max \$spef\n";
	print $fh "read_sdc -echo \$sdc\n";	
	print $fh "find_timing -full_update\n\n";
	#if ($target_cellname =~ m/^TBUF*?/) {
	#	print $fh "report_checks -path_delay max -rise_from IN -to OUT -unconstrained > $path_report\n";
	#	print $fh "write_path_spice -path_args \{-path_delay max -rise_from IN -to OUT -unconstrained\} -spice_directory $spice_dir -lib_subckt_file $cdl_spice_netlist -model_file $model -power $power_net -ground $ground_net\n";
	#}
	#else { 
	print $fh "report_checks -path_delay max -from IN -to OUT -unconstrained > $path_report\n";
	print $fh "write_path_spice -path_args \{-path_delay max -from IN -to OUT -unconstrained\} -spice_directory $spice_dir -lib_subckt_file $cdl_spice_netlist -model_file $model -power $power_net -ground $ground_net\n";
	#}
	#print $fh "write_path_spice -path_args \{-path_delay max -from IN -to OUT -unconstrained\} -spice_directory $spice_dir -lib_subckt_file $cdl_spice_netlist -model_file $model\n";
	print $fh "exit\n";
	close $fh;
}

sub gen_tempus_tcl 
{
	my ($tcl, $lib, $verilog, $sdc, $spef, $corner, $log_file, $path_report) = @_;
	open (my $fh, ">", $tcl)
		 or die " $tcl: $!"; 

	## scripts for OpenSTA
	#print $fh "set log_file \"$log_file\"\n";
	print $fh "set design top\n";

	print $fh "set libdir \"\.\/\"\n";

	print $fh "set lib_tt \"$lib \"\n";

	print $fh "set lib_tt_mem \"\"\n";

	#print $fh "log_begin \"$log_file\"\n";

	print $fh "set list_lib \"\$lib_tt \$lib_tt_mem\"\n";

	print $fh "# Target library\n";
	#print $fh "set link_library \$list_lib\n";
	#print $fh "set target_library \$list_lib\n\n";
	print $fh "set netlist $verilog\n";
	print $fh "set sdc $sdc\n";
	print $fh "set spef $spef\n\n";
	#print $fh "define_corners $corner\n";

	#print $fh "foreach lib \$list_lib {\nread_liberty -corner $corner \$lib\n}\n";

	print $fh "read_verilog \$netlist\n";

	print $fh "read_lib \$list_lib\n";
	print $fh "set_top_module \$design\n";
	print $fh "create_rc_corner -name Cmax\n";
	print $fh "read_spef \$spef\n";
	print $fh "read_sdc \$sdc\n";	
	print $fh "update_timing -full\n";
	print $fh "report_analysis_summary -merged_groups\n";
	print $fh "report_timing -from IN -to OUT -unconstrained > $path_report\n";
	print $fh "create_spice_deck -outdir $tempus_spice_dir -subckt_file $cdl_spice_netlist -model_file $model -power $power_net -ground $ground_net -report_timing \"-retime path_slew_propagation -from IN -to OUT -unconstrained\"\n";
	print $fh "exit\n";
	close $fh;
}

sub gen_sdc_file 
{
	my ($sdc_file, $input_slew) = @_;
	open (my $fh, ">", $sdc_file)
		 or die " $sdc_file: $!"; 

	## sdc file
	print $fh "set clock_cycle 100.0\n";
	print $fh "set uncertainty 0.0\n";
	print $fh "set io_delay 0.0\n";

	print $fh "set clock_port CLK\n";

	print $fh "create_clock -name CLK -period \$clock_cycle [get_ports \$clock_port]\n";
	print $fh "set_input_transition $input_slew IN\n";
	
	close $fh;
}


sub get_input_pin_info {
	my ($input_pin_list_filename) = @_;
	open(my $fin, '<', $input_pin_list_filename)
		or die "Can't Open < $input_pin_list_filename: $!";
	my @Input_Pin;
	while (<$fin>)
	{
		chomp($_);
		my @tmp = split(/ /, $_);
		push @Input_Pin, @tmp;
	}
	#print "@Input_Pin\n";
	close($fin);
	return \@Input_Pin;
}

sub get_unit
{
	my ($str, $field) = @_;
	my $unit = 'f';
	my @tmp = split(/[\s\:\"\ds\;\(\)\,\n\.]+/, $str);
	for(my $i =0; $i<@tmp; $i=$i+1 )
	{
		#print("$tmp[$i]|");
		if($tmp[$i] eq $field)
		{
			$unit = $tmp[$i+1];
		}
	}	
	return $unit;
}

sub read_slew_rate_table_from_lib
{
	my ($lib_filename, $target_cellname) = @_;
	#print("$lib_filename, $target_cellname");
	my @cell_input_pins;
	my @cell_output_pins;
	open(my $fin, '<', $lib_filename)
		or die "Can't open < $lib_filename: $!";
        my $lib_check_file_name = $pin_check_folder.$target_cellname."_pin.log";
	open(my $fout, '>', $lib_check_file_name )
		or die "Can't open > $lib_check_file_name: $!";

	my $table_name = "";
	my $time_unit;
	my $cap_unit;
	my $slew_lower_threshold_pct_fall=50;
	my $slew_lower_threshold_pct_rise=50;
	my $slew_upper_threshold_pct_fall=50;
	my $slew_upper_threshold_pct_rise=50;
	my @index1;
	my @index2;
	while(<$fin>)
	{
		# Time Units
		if($_ =~ m/\s*time\_unit.?/)
		{
			#print $_;
			#print "\n";
			$time_unit = get_unit($_, "time_unit");
		}
		elsif($_ =~ m/\s*capacitive\_load\_unit.?/)
		{
			$cap_unit = get_unit($_, "capacitive_load_unit");
			if ($cap_unit eq "\\") # Change line
			{
				my $str = <$fin>;
				my @tmp = split(/[\t\s\:\"\ds\;\(\)\,\n]+/, $str);
				$cap_unit = substr($tmp[1], 0 ,1);
			}
			else
			{
				$cap_unit = substr($cap_unit, 0 ,1);
			}
		}
		elsif($_ =~ m/\s*slew\_lower\_threshold\_pct\_fall.?/)
		{
			my @tmp = split(/[\t\s\:\;]+/, $_);
			$slew_lower_threshold_pct_fall = $tmp[2];
			#print("slew lower fall: $tmp[2]\n");
		}
		elsif($_ =~ m/\s*slew\_lower\_threshold\_pct\_rise.?/)
		{
			my @tmp = split(/[\t\s\:\;]+/, $_);
			$slew_lower_threshold_pct_rise = $tmp[2];
			#print("slew lower rise: $tmp[2]\n");
		}
		elsif($_ =~ m/\s*slew\_upper\_threshold\_pct\_fall.?/)
		{
			my @tmp = split(/[\t\s\:\;]+/, $_);
			$slew_upper_threshold_pct_fall = $tmp[2];
			#print("slew upper fall: $tmp[2]\n");
		}
		elsif($_ =~ m/\s*slew\_upper\_threshold\_pct\_rise.?/)
		{
			my @tmp = split(/[\t\s\:\;]+/, $_);
			$slew_upper_threshold_pct_rise = $tmp[2];
			#print("slew upper rise: $tmp[2]\n");
		}

		# Cell name
		if($_ =~ m/\s+cell\s*\(.?/ or $_ =~ m/\s+cell\(.?/ or  $_ =~ m/cell\s*\(.?/ or $_ =~ m/cell\(.?/)
		{	
			#print($_);
			my @cell = split(/[\t\(\)\{\s]+/, $_);
			my $cellname;
			for(my $i =0; $i<@cell; $i=$i+1 )
			{
				if($cell[$i] eq "cell")
				{
					$cellname = $cell[$i+1];
				}
			}
			#my $cellname = $cell[2];
			if ($cellname eq $target_cellname)
			{
				print ("Find cell $cellname\n");
				# Find the table name
				while(my $row = <$fin>)
				{
					if($row =~ m/\s*cell\_rise\s*\(.?/)
					{
						#print($row);
						my @table = split(/[\s()\{]+/, $row);
						for(my $i =0; $i<@table; $i=$i+1 )
						{
							if($table[$i] eq "cell_rise")
							{
								$table_name = $table[$i+1];
							}
						}
						#$table_name = $table[1];
						print ("Lookup Table Name: $table_name\n");
						#last;
						$row = <$fin>;
						if($row =~ m/\s*index_\d\s*\(.?/)
						{
							# make sure it is index
							print("cell index1: ", $row);
							@index1 = split(/[\s()\{\"\,]+/, $row);
							$row = <$fin>;
							print("cell index2: ",$row);
							@index2 = split(/[\s()\{\"\,]+/, $row);
						}
					}
					# find cell pins
					#print("row: ", $row);
					if($row =~ m/\s+pin\s+\(\w+\)\s+/ or $row =~ m/\s+pin\(\w+\)*/)
					{
						$row =~ s/^\s+//;
						print("row: ", $row);
						my @string = split(/[\s\(\)\:\{\}]+/, $row);
						my $pin_name = $string[1];
						#for(my $i=0; $i<@string; $i=$i+1)
						#{
						#	print($i," ", $string[$i], "\n");
						#}
						#my $next_row = <$fin>;
						while(my $next_row = <$fin>)
						{
							$next_row =~ s/^\s+//;
							print("$next_row\n");
							if($next_row =~ m/direction\s*\:\s*\w*/)
							{
								my @string = split(/[\s\:\(\)\{\}\;\"]+/, $next_row);
								if ($string[1] eq "input")
								{
									#print($string[1]);
									push(@cell_input_pins, $pin_name);
								}
								else 
								{			
									push(@cell_output_pins, $pin_name);
								}
								for(my $i=0; $i<@string; $i=$i+1)
								{
									print($i, " ", $string[$i], "\n");
								}
								last;
							}
						}
						
					}
					#if($row =~ m/\s*cell\s*\(.?/)
					if($row =~ m/\s+cell\s*\(.?/ or $row =~ m/\s+cell\(.?/ or $row =~ m/\s*cell\(.?/ or  $row =~ m/cell\s*\(.?/ or $row =~ m/cell\(.?/)
					{
						last;
					}
				}
				last;
			}
		}	
	}
	close($fin);

	my @input_slew_raw;
	if ($table_name ne "")
	{
		# Find the transition table 
		open($fin, '<', $lib_filename)
			or die "Can't open < $lib_filename: $!";

		while(<$fin>)
		{
			if($_ =~ m/\s*lu_table_template\s*\(.?/)
			{
				my @lu_table = split(/[\s()\{]+/, $_);	
				my $lu_table_name;
				#foreach my $tmp1 (@lu_table)
				#{
				#	print ("$tmp1 |");
				#}
				for(my $i =0; $i<@lu_table; $i=$i+1 )
				{
					if($lu_table[$i] eq "lu_table_template")
					{
						$lu_table_name = $lu_table[$i+1];
					}
				}

				if($lu_table_name eq $table_name)
				{
					my $num = 1;
					while(my $row = <$fin>)
					{
						if($row =~ m/\s*variable_\d\s*.?/ and $row =~ m/\s*.input_net_transition.?/)
						{
							print ("input net transition", $row);
							if ($num == 1) {
								@input_slew_raw = @index1;
								last;
							}
							if ($num == 2) {
								@input_slew_raw == @index2;
								last;
							}
							$num = $num + 1;
						}
						#if($row =~ m/\s*index_1\s*\(.?/)
						#{
						#	@input_slew_raw = split(/[\s()\}\,\"\;]+/, $row);
							#foreach my $tmp (@input_slew_raw)
							#{
							#	print "$tmp |";
							#}
						#	last;
						#}

					}
					last;	
				}
			}	

		}
	}
	close($fin);
	# reorganize input slew matrix
	my @input_slew_matrix;
	foreach my $tmp (@input_slew_raw)
	{
		if($tmp =~ m/^\d+/)
		{
			#print ("$tmp ");
			push (@input_slew_matrix, $tmp);
		}
	}
	print ("Input slew: ");
	print $fout "time unit: $time_unit, cap unit: $cap_unit\n";
	print $fout "Input slew: ";
	
	foreach my $slew(@input_slew_matrix)
	{
		print("$slew ");
		print $fout "$slew ";
	}
	print("\n");
	print $fout "\n";
	
	print $fout "$target_cellname \(";
	foreach my $in_pin (@cell_input_pins)
	{
		print $fout "$in_pin ";
	}
	foreach my $out_pin (@cell_output_pins)
	{
		print $fout "$out_pin ";
	}
	print $fout ")";

	close($fout); 
	return ($time_unit, $cap_unit, \@input_slew_matrix, $slew_lower_threshold_pct_fall, 
		$slew_lower_threshold_pct_rise, $slew_upper_threshold_pct_fall, $slew_upper_threshold_pct_rise, \@cell_input_pins, \@cell_output_pins);
}

sub read_meas_file
{
	my ($filename) = @_;
	open(my $fin, '<', $filename)
		or die "Can't open < : $filename: $!";
	print("\n============================ \n Collecting measurement from $filename ... \n============================\n");
	my @meas_arr;
	my $meas_col_cnt = 0;
	# skip title
	<$fin>;
	<$fin>;
	while(<$fin>)
	{
		chomp($_);
		# trim left and right space
		$_ =~ s/^[\s\t]+|[\s\t]+$//g; 
		#print($_);
		
		if($_ =~ m/(^\d|^\-\d)/)
		{
			# Measure Value
			my @tmp = split(/[\t\s]+/, $_);
			for( my $i=0; $i<@tmp; $i=$i+1)
			{
				#print ("$tmp[$i] |");
				push (@{$meas_arr[$meas_col_cnt]}, $tmp[$i]);
				if($meas_col_cnt < @meas_arr)
				{ 
					$meas_col_cnt = $meas_col_cnt + 1;
				}
				else
				{
					$meas_col_cnt = 0;
				}
			}

		}
		#elsif($_ =~ m/^\D/)
		else
		{
			# Measure Name
			my @tmp = split(/[\t\s]+/, $_);
			foreach my $meas_field (@tmp)
			{
				#print ("$meas_field |");
				my @arr = [$meas_field];
				push(\@meas_arr, @arr);
			}
		} 
	}
	#print Dumper \@meas_arr;
	close($fin);
	return (\@meas_arr);
}

sub get_measure_objects
{
	my ($arr_add) = @_;
	my $obj="none";
	my @pins;
	my @arr = @{$arr_add};
	foreach my $s (@arr)
	{
		if($s =~ m/[dD][Ee][lL][aA][yY]/ or $s =~ m/[sS][lL][eE][wW]/)
		{
			$obj = $s;	
		}
		elsif($s =~ m/^[uUOoIi]/)
		{
			push (@pins, $s);	
		}
	}
	return ($obj, \@pins);

}

sub extract_measure_value
{
	my ($spicemeasname) = @_;
	my $Gen_meas_arr_add = read_meas_file($spicemeasname);
	my @Gen_meas_arr = @{$Gen_meas_arr_add};
	
	open (my $fh, ">>", "Gen_summary.txt")
		 or die " Gen_summary.txt: $!"; 
	print $fh "=======================$spicemeasname========================\n";
	
	for(my $i = 0; $i < @Gen_meas_arr; $i = $i+1)
	{
		print $fh "$Gen_meas_arr[$i][0]			$Gen_meas_arr[$i][1]\n";
	}
	close($fh);
}

sub compare_sta2spice_measure
{
	my ($STA_reportname, $Gen_spicemeasname, $Summary_filename, $istempus) = @_;
	my $STA_path_delay = 0;
	if($istempus == 1) 
	{
		$STA_path_delay = read_tempus_report($STA_reportname);	
	}
	else
	{
		$STA_path_delay = read_sta_report($STA_reportname);
	}
	my $Gen_meas_arr_add = read_meas_file($Gen_spicemeasname);
	my @Gen_meas_arr = @{$Gen_meas_arr_add};
	my $Error_filename = $Summary_filename."_error";
	#print ("STA measurement\n");
	
	# Open a handle to the file "new.csv"
	my $header = 0;
	if( not (-e $Summary_filename))
	{
		$header = 1;
	}
	else
	{
		$header = 0;
	}
 	open (my $fh, ">>", $Summary_filename)
		 or die " $Summary_filename: $!";
	open (my $fh1, ">>", $Error_filename)
		 or die " $Error_filename: $!";
	if( $header == 1)
	{ 
		print $fh "Name	STA Path Delay Value	SPICE Path Delay Value\tError\tRelative Error\(\%\)\n";	
		print $fh1 "Name	STA Path Delay Value	SPICE Path Delay Value\tError\tRelative Error\(\%\)\n";	
	}
	# Compare the result betweens them
	my $spice_path_delay = 0;
	for(my $g = 0; $g < @Gen_meas_arr; $g = $g+1)
	{
		my @tmp1 = split(/\_/,$Gen_meas_arr[$g][0]);
		my ($obj1, $pins_add1) = get_measure_objects(\@tmp1);
		my @pins1 = @{$pins_add1};
		if( $obj1 ne "none")
		{
			
			if($Gen_meas_arr[$g][0] =~ m/delay/)
			{
				# compare
				#print("$STA_meas_arr[$i][0] $STA_meas_arr[$i][1], $Gen_meas_arr[$g][0] $Gen_meas_arr[$g][1]\n");
				if($istempus==1)
				{
					if($Gen_meas_arr[$g][0] =~ m/data_path/)
					{		
						print "	$Gen_meas_arr[$g][0]			$Gen_meas_arr[$g][1]\n";
						$spice_path_delay = $Gen_meas_arr[$g][1];
					}
				}
				else
				{
					print "	$Gen_meas_arr[$g][0]			$Gen_meas_arr[$g][1]\n";
					$spice_path_delay = $spice_path_delay + $Gen_meas_arr[$g][1];
				}
			}
		}	
	}
        my $abs_err = $STA_path_delay - $spice_path_delay;
        my $rel_err = $abs_err*100/$STA_path_delay;
	print $fh "$STA_reportname\t$STA_path_delay\t$spice_path_delay\t$abs_err\t$rel_err\n";
	if (abs($abs_err) > 3e-9) {
		print $fh1 "$STA_reportname\t$STA_path_delay\t$spice_path_delay\t$abs_err\t$rel_err\n";
	}
	close($fh);
}

sub read_sta_report
{
	my ($sta_report_name) = @_;
	print("Reading $sta_report_name\n");
	open(my $fin, '<', $sta_report_name)
		or die "Can't open < : $sta_report_name: $!";
	while(<$fin>)
	{
		#print $_;	
		$_ =~ s/^\s+//;
		my @str = split(/[\t\s]+/, $_); 
		if (@str>4)
		{
			if ($str[3] eq "OUT")
			{
				close($fin);
				my $delay = $str[1]*word2number($time_unit);
				return $delay;
			}
		}
		#foreach my $s (@str)
		#{
		#	print($s, " ");
		#}
		#print "\n";

	}
	close($fin);
}

sub read_tempus_report
{
	my ($sta_report_name) = @_;
	print("Reading $sta_report_name\n");
	open(my $fin, '<', $sta_report_name)
		or die "Can't open < : $sta_report_name: $!";
	while(<$fin>)
	{
		#print $_;	
		$_ =~ s/^\s+//;
		my @str = split(/[\t\s]+/, $_); 
		if (@str>5)
		{
			if ($str[1] eq "OUT")
			{
				close($fin);
				my $delay = $str[5]*word2number($time_unit);
				return $delay;
			}
		}
		#foreach my $s (@str)
		#{
		#	print($s, " ");
		#}
		#print "\n";

	}
	close($fin);
}

sub word2number
{
	my ($word) = @_;
	if($word =~ m/[u|U]/)
	{
		return 1e-6;
	}
	elsif($word =~ m/[n|N]/)
	{
		return 1e-9;
	}
	elsif ($word =~ m/[p|P]/)
	{
		return 1e-12;
	}
	elsif ($word =~ m/[f|F]/)
	{
		return 1e-15;
	}
	return 1;
}
