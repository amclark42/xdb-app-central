xquery version "3.0";

declare namespace wwp="http://www.wwp.northeastern.edu/ns/textbase";

<div>
  {
    let $requested := request:get-parameter('file', 'elizabeth.lastspeech')
    let $docPath := concat('../tb/files/', $requested, '.xml')
    let $stylesheet := doc('test_backends_01.xslt')
    return
      if ( doc-available($docPath) ) then
        transform:transform($doc, $stylesheet, <parameters/>)
      else
        <p>Could not find file {$requested}!</p>
  }
</div>
