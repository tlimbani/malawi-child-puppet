class openmrs {
    
	require pih_java
	require pih_tomcat
	require pih_mysql
	
	$pih_openmrs_home = "${pih_home}\\openmrs\\"
	$pih_openmrs_modules = "${pih_openmrs_home}\\modules\\"
	
	$pih_openmrs_modules_zip = "${pih_home}\\openmrs-modules.zip"
	$pih_openmrs_war = "${pih_tomcat_home}\\webapps\\openmrs.war"
	$pih_openmrs_runtime_properties = "${pih_openmrs_home}\\openmrs-runtime.properties"
	
	file { $pih_openmrs_home:
		ensure  => directory,
		require => File[$pih_home],
	} ->
	
	file { $pih_openmrs_modules_zip:
		ensure  => file,
		source	=> "puppet:///modules/openmrs/openmrs-modules.zip",		
	} -> 
	
	windows::unzip { $pih_openmrs_modules_zip:
		destination => $pih_openmrs_home,
		creates	=> $pih_openmrs_modules,
	} -> 
	
	file { $pih_openmrs_war:
		ensure  => file,
		source	=> "puppet:///modules/openmrs/openmrs.war",		
	} -> 
	
	file { $pih_openmrs_runtime_properties: 
		ensure  => present,
		provider => windows, 	
		content	=> template('openmrs/openmrs-runtime.properties.erb'),	
	} ->
	
	notify { 'pih_tomcat::stop_tomcat':}
	
}