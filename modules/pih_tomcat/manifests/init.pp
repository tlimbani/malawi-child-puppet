class pih_tomcat {
    
	require pih_java
	
	if $architecture == 'x64' { 
		$tomcat_zip = 'tomcat-6.0.32-x64.zip'
	} else {
		$tomcat_zip = 'tomcat-6.0.32.zip'
	}
	
	$pih_tomcat_zip = "${pih_home_bin}\\${tomcat_zip}"
	$pih_install_tomcat = "${pih_tomcat_home}\\bin\\install_tomcat.bat"
	
	file { $pih_tomcat_home:
		ensure  => directory,
		require => File[$pih_home],
	}
	
	file { $pih_tomcat_zip:
		ensure  => file,
		source	=> "puppet:///modules/pih_tomcat/${tomcat_zip}",		
		require => File[$pih_tomcat_home],
	}
	
	windows::unzip { $pih_tomcat_zip:
		destination => $pih_tomcat_home,
		creates	=> "${pih_tomcat_home}\\bin",
		require => File[$pih_tomcat_home],
	} ->
	
	windows::environment { 'CATALINA_HOME': 
		value	=>	$pih_tomcat_home,
		require => File[$pih_tomcat_home],
		notify	=> Class['windows::refresh_environment'],
	}  -> 
	
	exec { 'remove_tomcat': 
		path		=> $::path,
		cwd			=> "${pih_tomcat_home}\\bin", 
		provider	=> windows, 
		command		=> "cmd.exe /c set JAVA_HOME=${pih_java_home}&&service.bat remove",
		logoutput	=> true,
	} -> 
	
	exec { 'install_tomcat': 
		path		=> $::path,
		cwd			=> "${pih_tomcat_home}\\bin", 
		provider	=> windows, 
		command		=> "cmd.exe /c set JAVA_HOME=${pih_java_home}&&service.bat install",
		logoutput	=> true,
	} -> 
	
	exec { 'upgrade_tomcat_memory': 
		path		=> $::path,
		cwd			=> "${pih_tomcat_home}\\bin", 
		provider	=> windows, 
		command		=> "cmd.exe /c set JAVA_HOME=${pih_java_home}&&tomcat6 //US//Tomcat6 --JvmMx 512 ++JvmOptions=\"-XX:MaxPermSize=256m\"",
		logoutput	=> true,
	} ->
	
	notify { 'pih_tomcat::stop_tomcat':}
	
} 