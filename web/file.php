<?php
header('Content-type: application/json');

$files = glob('../8-outbox/*.JPG');
$file = $files[count($files)-1];
$file = basename($file);

echo json_encode(array(
  'filename' => '/photos/'.$file
));
