xquery version "3.0";

declare namespace wwp="http://www.wwp.northeastern.edu/ns/textbase";

<p>
 {
   let $requested := request:get-parameter('file', 'elizabeth.lastspeech')
   let $doc := doc(concat('../tb/files/', $requested, '.xml'))
   return
     $doc//wwp:title[@type eq 'main']
 }
</p>
