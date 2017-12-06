<#
    .Synopsis
      Display which RFC Destination has a hardcoded credential
    .Description
      Calls the function RFC_READ_TABLE on RFCDES table, through the /sap/bc/soap/rfc SOAP 
      $target like : http(s)://ip:port
    .Author
      @_1ggy
#>

#-Set Parameters
    Param(
    [parameter(Mandatory = $true, HelpMessage="target like : http(s)://ip:port")]
    [alias("t")]
    [string]$target,

    [parameter(Mandatory = $true)]
    [alias("c")]
    [string]$client,
  
    [parameter(Mandatory = $true)]
    [alias("u")]
    [string]$username,
    
    [parameter(Mandatory = $true)]
    [string]$password = $( Read-Host -asSecureString "Input password" )
    )

function WriteXmlToScreen ([xml]$xml)
{
    $StringWriter = New-Object System.IO.StringWriter;
    $XmlWriter = New-Object System.Xml.XmlTextWriter $StringWriter;
    $XmlWriter.Formatting = "indented";
    $xml.WriteTo($XmlWriter);
    $XmlWriter.Flush();
    $StringWriter.Flush();
    Write-Output $StringWriter.ToString();
}

function Execute-SOAPRequest 
{ 

$pair = "$($username):$($password)"

$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
$basicAuthValue = "Basic $encodedCreds"

$Headers = @{
        'SOAPAction' = 'urn:sap-com:document:sap:rfc:functions'
        'sap-client' = $client 
        'sap-language' = 'EN'
        Authorization = $basicAuthValue
    }

$postParams = '<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<env:Body>
    <n1:RFC_READ_TABLE xmlns:n1="urn:sap-com:document:sap:rfc:functions" env:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
        <DATA>
            <item>
                <WA></WA>
            </item>
        </DATA>
        <DELIMITER>|</DELIMITER>
        <FIELDS>
            <item><FIELDNAME>RFCDEST</FIELDNAME></item>
            <item><FIELDNAME>RFCTYPE</FIELDNAME></item>
            <item><FIELDNAME>RFCOPTIONS</FIELDNAME></item>
        </FIELDS>
        <OPTIONS>
            <item><TEXT>RFCOPTIONS like &apos;%PWD%&apos;</TEXT></item>
        </OPTIONS>
        <NO_DATA></NO_DATA>
        <QUERY_TABLE>RFCDES</QUERY_TABLE>
    </n1:RFC_READ_TABLE>
</env:Body>
</env:Envelope>'

$soapreq = Invoke-WebRequest $url -Method $method -ContentType "text/xml" -Body $postParams -Headers $Headers

WriteXmlToScreen $soapreq.Content
} 

#-Main

$url = $target+'/sap/bc/soap/rfc'
$method = 'post'

Execute-SOAPRequest  

#-End

