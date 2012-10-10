<%@ Page Language="VB" Debug="true" %>

<%@ Import Namespace="System.Xml" %>

<%@ Import Namespace="System.IO" %>

<%@ Import Namespace="System.Net" %>

<script runat="server">
      
  
    Dim req As HttpWebRequest
    Dim res As HttpWebResponse = Nothing
    Dim reader As StreamReader
    Dim address As Uri
    Dim appId As String
    Dim ctx As String
    Dim query As String
    Dim data As StringBuilder
    Dim byteData() As Byte
    Dim postStream As Stream = Nothing
    
    Sub Page_Load(Sender As Object, E As EventArgs)
       
        If IsPostBack Then

            
            'create xml
            Dim memory_stream As New MemoryStream
            Dim xml_text_writer As New XmlTextWriter(memory_stream, System.Text.Encoding.UTF8)

            xml_text_writer.WriteStartDocument(True)

            xml_text_writer.WriteStartElement("form1")

            xml_text_writer.WriteStartElement("name")
            xml_text_writer.WriteString(name.Value)
            xml_text_writer.WriteEndElement()
            xml_text_writer.WriteStartElement("age")
            xml_text_writer.WriteString(age.Value)
            xml_text_writer.WriteEndElement()

            ' End the document.
            xml_text_writer.WriteEndDocument()
            xml_text_writer.Flush()

            ' Use a StreamReader to display the result.
            Dim stream_reader As New StreamReader(memory_stream)

            memory_stream.Seek(0, SeekOrigin.Begin)
            Dim xdata = stream_reader.ReadToEnd()
            xml_text_writer.Close()
            
            
            'rest endpoint for process 
            Dim url As String = "http://192.168.1.9:8080/rest/services/SampleApplication/Sample:1.0"
            
            address = New Uri(url)
            
            req = DirectCast(WebRequest.Create(url), HttpWebRequest)
            req.Method = "POST"
            req.ContentType = "application/x-www-form-urlencoded"

            'username/password for livecycle server
            req.Credentials = New NetworkCredential("sample", "sampletest")
            
            'take form fields an assign to livecycle process input variables
            data = New StringBuilder()
            data.Append("xml=" + HttpUtility.UrlEncode(xdata))
            data.Append("&form=" + HttpUtility.UrlEncode(form.Value))

            byteData = UTF8Encoding.UTF8.GetBytes(data.ToString())
            req.ContentLength = byteData.Length
  
            postStream = req.GetRequestStream()
            postStream.Write(byteData, 0, byteData.Length)
         
            'get response from livecycle
            res = DirectCast(req.GetResponse(), HttpWebResponse)

            'get binary data of pdf from livecycle and display to user
            Dim filesize As Long = res.ContentLength
            Dim buffer(filesize) As Byte
            res.GetResponseStream().Read(buffer, 0, filesize)

            Response.ContentType = "application/pdf"
            Response.BinaryWrite(buffer)

            
            Response.End()
            
        
        End If
        
        
    End Sub
    
</script>

<html>

<head>
<title>livecycle test</title>
</head>
<body>
    
<form action="default.aspx" method="post" runat="server">
    <label for="name">Name:</label>
    <input type="text" id="name" name="name" runat="server" /><br />

    <label for="name">Age:</label>
    <input type="text" id="age" name="age" runat="server" /><br />


    <label for="form">Form:</label>
    <select id="form" name="form" runat="server" >
           <option value="form1">Form 1</option>
           <option value="form2">Form 2</option>
    </select><br />
    <input type="submit" />

</form>

</body>
</html>
