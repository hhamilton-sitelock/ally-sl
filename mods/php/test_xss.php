<?php
$reports = array(); //holds report of what is going on

if(isset($argv[1]) && is_string($argv[1])) {
	$url_input = html_entity_decode($argv[1]);
	$url_parts = parse_url($url_input);
		
	$scheme = 'http';
	extract($url_parts); // schema, host, port, path query
	
	if(!isset($host) || !isset($query)) {
		//error message
		echo 'Your url must have a host and query string' . 
			'Example: text_xss.php \'http://website.com?parm=1&param=2\'' . "\n";
		exit;
	}
	
	$url = $scheme . '://' . $host . (isset($port) ? ':'.$port : '') . (isset($path) ? $path : '');
	parse_str($query, $query_array);

	
	/********* REQUEST_URI and/or QUERY_STRING vulnerability *********/
	setQueryVal($query_array, '<script>alert("corneliuslamb")</script>', $uri_q); //value stored in uri_q (setting all query values to corn)
	$new_query = urldecode(http_build_query($uri_q));

	$getContents = getContents($url, $uri_q);
	
	$contents = urldecode($getContents['contents']);
	$found_xss = 0;
	
	file_put_contents('query', $contents);
	if(strstr($contents, $new_query)) {
		$found_xss = 1;
		$reports[] = 'Either $_SERVER[\'REQUEST_URI\'] or $_SERVER[\'QUERY_STRING\'] is unsanitized recomended to use urlencode on where variable is being spit out.';
	}
	
	//double check with out redirect
	if(!$found_xss && $getContents['info']['http_code'] != 200) {
		$getContents = getContents($url, $uri_q, 0, array(CURLOPT_FOLLOWLOCATION => false));
		$contents = urldecode($getContents['contents']);
		file_put_contents('query', $contents);
		
		if(strstr($contents, $new_query)) {
			$reports[] = 'Either $_SERVER[\'REQUEST_URI\'] or $_SERVER[\'QUERY_STRING\'] is unsanitized recomended to use urlencode on where variable is being spit out.';
		}
	}
	/********* END REQUEST_URI and/or QUERY_STRING vulnerability *********/
	
	/********* SCRIPT TAG vulnerability *********/
	setQueryVal($query_array, '', $uri_q, 1, '<script>alert("', '")</script>');

	//GET
	$getContents = getContents($url, $uri_q);
	$get_content = stripslashes($getContents['contents']);
	$found_xss = 0;
	
	file_put_contents('get', $get_content);
	preg_match_all('@<script>alert\("(.+?)"\)</script>@', $get_content, $get_matches);
	if(isset($get_matches[1]) && count($get_matches[1])) {
		$found_xss = 1;
		$reports[] = 'The following GET parameters have vulnerabilities: ' . "'". implode("', '", getParams($get_matches[1])) ."'";
	}
	
	//double check
	if(!$found_xss && $getContents['info']['http_code'] != 200) {
		$getContents = getContents($url, $uri_q, 0, array(CURLOPT_FOLLOWLOCATION => false));
		$get_content = stripslashes($getContents['contents']);
		file_put_contents('get', $get_content);
		
		if(isset($get_matches[1]) && count($get_matches[1])) {
			$reports[] = 'The following GET parameters have vulnerabilities: ' . "'". implode("', '", getParams($get_matches[1])) ."'";
		}
	}
	
	
	//POST
	$getContents = getContents($url, $uri_q, 1);
	$post_content = stripslashes($getContents['contents']);
	$found_xss = 0;
	
	preg_match_all('@<script>alert\("(.+?)"\)</script>@', $post_content, $post_matches);
	file_put_contents('post', $post_content);
	if(isset($post_matches[1]) && count($post_matches[1])) {
		$found_xss = 1;
		$reports[] = 'The following POST parameters have vulnerabilities: ' . "'". implode("', '", getParams($post_matches[1])) ."'";
	}
	
	//double check
	if(!$found_xss && $getContents['info']['http_code'] != 200) {
		$getContents = getContents($url, $uri_q, 1, array(CURLOPT_FOLLOWLOCATION => false));
		$post_content = stripslashes($getContents['contents']);
		file_put_contents('post', $post_content);
		
		if(isset($post_matches[1]) && count($post_matches[1])) {
			$reports[] = 'The following POST parameters have vulnerabilities: ' . "'". implode("', '", getParams($post_matches[1])) ."'";
		}
	}

	if(count($reports)) {
		foreach($reports as $report) {
			echo $report . "\n";
		}
	}
	else {
		echo 'There were no XSS vulnerabilites detected' . "\n";
	}
	/********* END SCRIPT TAG vulnerability *********/
}
else {
	//error message
	echo 'You must supply a string argument' . "\n" .
		'Example: text_xss.php \'http://website.com?parm=1&param=2\'' . "\n";
}

function getContents($url, $query, $post=0, $opts=array()) {
	$ch  = curl_init();
	$options[CURLOPT_URL] = $url;
	
	if($post) {
		$options[CURLOPT_POST] = true;
		$options[CURLOPT_POSTFIELDS] = http_build_query($query);
	}
	else {
		
		$options[CURLOPT_URL] .= '?' . http_build_query($query);
	}
	
	//COOKIE MANAGEMENT
	$cookie_file = 'cookie.txt';
	$options[CURLOPT_COOKIE] = $cookie_file;
    $options[CURLOPT_COOKIEFILE] = $cookie_file;
    $options[CURLOPT_COOKIEJAR] = $cookie_file;
    //$options[CURLOPT_COOKIE] = 'person=corn';
    $options[CURLOPT_COOKIESESSION] = true;

	$options[CURLOPT_RETURNTRANSFER] = true;
	//$options[CURLOPT_FOLLOWLOCATION] = true;
	$options[CURLOPT_USERAGENT] = 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)';
	
	if(substr($url, 0, 5) == 'https') {
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
	}
	
	if(count($opts)) {
		$options += $opts;
	}

	@curl_setopt_array($ch, $options);
	
	$contents = curl_exec($ch);
	$info = curl_getinfo($ch);
	
	curl_close($ch);
	
	return array(
		'contents' => $contents,
		'info' => $info
	);
}

function setQueryVal($keys, $val, &$holder, $same_as_key=0, $pre='', $post='') {
	global $key_name;
	
	foreach($keys as $key => $v) {
		$key_name[] = $key;
		
		if(is_array($v)) {
			setQueryVal($v, $val, $holder[$key], $same_as_key, $pre, $post);
			array_pop($key_name);
		}
		else {
			$holder[$key] = $pre . ($same_as_key ? implode('|', $key_name) : $val) . $post;
			array_pop($key_name);
		}
	}
}

function getParams($params) {
	$vals = array();
	foreach($params as $param) {
		$p = explode('|', $param);
		$str = '';
		
		for($i=0; $i < count($p); $i++) {
			if($i == 0)
				$str = $p[$i];
			else
				$str .= '['.$p[$i].']';
		}
		
		$vals[$str] = $str;
	}
	
	return $vals;
}
