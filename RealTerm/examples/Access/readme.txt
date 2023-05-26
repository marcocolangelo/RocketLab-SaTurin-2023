MS Access example contrtributed by Alois Leimueller
 
hello,
I tested the Realterm-ActiveX-Interface with Realterm 2.0.0.70 and
Access 2003.
In the documentation you wrote that you need a example for event
handling with Excel.
I have a working example for Microsoft Access 2003. Please find attached
the zip file.
If you find it helpful, you may optimize and publish it with your other
examples.

My example is not perfect. But I am glad it finally works.
Now I have a problem:
The 2 lines
.DataTriggerSet 1, "", vbCr, 0, 0, True, True, False
.EnableDataTrigger 1
are not working as expected.
The checkboxes for "Packet End condition/when this string is received"
and "packet is initially enabled" should be activated with my VB-Code.
Please can you give me a hint ?

thanks
Alois Leimueller