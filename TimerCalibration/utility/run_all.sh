
./run_calibrate_gscl45nm.lib.sh
mv OpenSTA_Summary_Report.txt OpenSTA_Summary_Report_Free45PDK.txt
python statistical_data_gen.py OpenSTA_Free45PDK OpenSTA_Summary_Report_Free45PDK.txt OpenSTA_Summary_Report_Free45PDK.report
