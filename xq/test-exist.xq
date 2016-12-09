xquery version "3.0";

declare namespace wwp="http://www.wwp.northeastern.edu/ns/textbase";

<p>
 {
   let $requested := request:get-parameter('file', 'elizabeth.lastspeech')
   let $doc := doc(concat('../tb/files/', $requested, '.xml'))
   let $stylesheet := doc('test_backends_01.xslt')
   return
     transform:transform($doc, $stylesheet, <parameters/>)
 }
</p>
