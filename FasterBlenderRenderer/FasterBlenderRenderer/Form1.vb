Imports System.IO
Imports System.IO.Compression
Public Class Form1
    Dim Renderstring As String
    Dim appdata As String = My.Computer.FileSystem.SpecialDirectories.CurrentUserApplicationData & "\LKrenderer"
    Dim Blenderversion As String
    Dim Downloadversion As String
    Dim rendering As Boolean = False
    Private Sub TrackBar1_Scroll(sender As Object, e As EventArgs) Handles TrackBar1.Scroll
        CheckBox2.Text = "Single Frame (Framme number: " & TrackBar1.Value & ")"
    End Sub
    Private Sub Form1_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        If System.IO.Directory.Exists(appdata) = False Then
            System.IO.Directory.CreateDirectory(appdata)
            System.IO.Directory.CreateDirectory(appdata & "\BV")
            System.IO.Directory.CreateDirectory(appdata & "\RenderedPics")
            Dim fs As FileStream = File.Create(appdata & "\DownloadedVersions.txt")
            Dim fs1 As FileStream = File.Create(appdata & "\readme.txt")
            fs.Close()
            fs1.Close()
            My.Computer.FileSystem.WriteAllText(appdata & "\readme.txt",
            "This is the directory where everything for LK-Renderer is stored. " & vbCrLf &
            "############   Please do not modify any Files here    ##############" &
            "############   If you modify anything here programm may not functon anymore  #########", True)
        End If
    End Sub
    Private Sub CheckBox2_CheckedChanged(sender As Object, e As EventArgs) Handles CheckBox2.CheckedChanged
        If CheckBox2.Checked = True Then
            CheckBox1.Checked = False
        End If
    End Sub
    Private Sub Button1_Click(sender As Object, e As EventArgs) Handles Button1.Click
        MsgBox("After you hit the Button a Command-line Window will show up and render your image." & vbCrLf & "This window will automaticly be closen after your render has finished!")
        If ComboBox2.Text = "Cycles" Then
            If CheckBox2.Checked = True Then
                Renderstring = "blender.exe -b " & TextBox1.Text & " -E CYCLES" & " -o " & TextBox2.Text & "\Renderdpic_###.png" & " -t " & TrackBar2.Value & " -f " & TrackBar1.Value
            End If
            If CheckBox1.Checked = True Then
                Renderstring = "blender.exe -b " & TextBox1.Text & " -E CYCLES" & " -o " & TextBox2.Text & "\Renderdpic_###.png" & " -s " & TrackBar3.Value & " -e " & TrackBar4.Value & " -t " & TrackBar2.Value & " -a "
            End If
        End If
        If ComboBox2.Text = "Internal Blender Renderer" Then
            If CheckBox2.Checked = True Then
                Renderstring = "blender.exe -b " & TextBox1.Text & " -E BLENDER_RENDER" & " -o " & TextBox2.Text & "\Renderdpic_###.png" & " -t " & TrackBar2.Value & " -f " & TrackBar1.Value
            End If
            If CheckBox1.Checked = True Then
                Renderstring = "blender.exe -b " & TextBox1.Text & " -E BLENDER_RENDER" & " -o " & TextBox2.Text & "\Renderdpic_###.png" & " -s " & TrackBar3.Value & " -e " & TrackBar4.Value & " -t " & TrackBar2.Value & " -a "
            End If
        End If
        Try
            Shell(appdata & "\BV_R\blender-" & ComboBox1.SelectedItem & "-windows64\" & Renderstring)
            rendering = True
            Timer1.Enabled = True
        Catch ex As Exception
            MsgBox("Error:" & ex.Message)
        End Try
    End Sub
    Private Sub CheckBox1_CheckedChanged(sender As Object, e As EventArgs) Handles CheckBox1.CheckedChanged
        If CheckBox1.Checked = True Then
            CheckBox2.Checked = False
        End If
    End Sub
    Private Sub Button3_Click(sender As Object, e As EventArgs) Handles Button3.Click
        MsgBox("Select the .blend file you want To use!")
        Dim openFileDialog1 As New OpenFileDialog()
        openFileDialog1.InitialDirectory = "c:\"
        openFileDialog1.Filter = ".blend Files (*.blend)|*.blend|All files (*.*)|*.*"
        openFileDialog1.FilterIndex = 1
        openFileDialog1.RestoreDirectory = True
        If openFileDialog1.ShowDialog() = System.Windows.Forms.DialogResult.OK Then
            TextBox1.Text = openFileDialog1.FileName
        End If
    End Sub
    Private Sub Button2_Click_1(sender As Object, e As EventArgs) Handles Button2.Click
        Try
            Dim fileReader As String
            fileReader = My.Computer.FileSystem.ReadAllText(appdata & "\DownloadedVersions.txt")
            If InStr(fileReader, ComboBox1.SelectedItem) = 0 Then
                MsgBox("Starting to download Blender " & ComboBox1.SelectedItem & vbCrLf & "Window might seem inactive but in the Background the Blender-Version is being downloaded!" & vbCrLf & "When an error occurs a messagebox will pop up when the Blender-Version was downloaded a messagebox will pop up!")
                Downloadversion = "http://download.blender.org/release/Blender" & ComboBox1.SelectedItem & "/blender-" & ComboBox1.SelectedItem & "-windows64.zip"
                download(Downloadversion, appdata & "\BV\" & ComboBox1.SelectedItem & ".zip")
            End If
            If InStr(fileReader, ComboBox1.SelectedItem) > 0 Then
                MsgBox("The selected Blender-Version has already been Downloaded")
            End If
        Catch ex As Exception
            MsgBox("Error " & ex.Message)
        End Try
    End Sub
    Private Sub Button5_Click(sender As Object, e As EventArgs) Handles Button5.Click
        Dim fileReader As String
        fileReader = My.Computer.FileSystem.ReadAllText(appdata & "\DownloadedVersions.txt")
        MsgBox(fileReader)
    End Sub
    Private Sub Button4_Click(sender As Object, e As EventArgs) Handles Button4.Click
        Dim FolderBrowser As New FolderBrowserDialog
        FolderBrowser.Description = "Select an outputpath for the image"
        FolderBrowser.ShowNewFolderButton = True
        FolderBrowser.SelectedPath = My.Computer.FileSystem.SpecialDirectories.Desktop
        If FolderBrowser.ShowDialog = DialogResult.OK Then
            TextBox2.Text = FolderBrowser.SelectedPath
        End If
    End Sub
    Private Sub TrackBar2_Scroll(sender As Object, e As EventArgs) Handles TrackBar2.Scroll
        Label5.Text = "# of threads (" & TrackBar2.Value & ") 0 for # of processor cores"
    End Sub
    Private Sub TrackBar3_Scroll(sender As Object, e As EventArgs) Handles TrackBar3.Scroll
        Label7.Text = "Start Frame (" & TrackBar3.Value & ")"
    End Sub
    Private Sub TrackBar4_Scroll(sender As Object, e As EventArgs) Handles TrackBar4.Scroll
        Label8.Text = "End Frame (" & TrackBar4.Value & ")"
    End Sub
    Private Sub Timer1_Tick(sender As Object, e As EventArgs) Handles Timer1.Tick
        If CheckBox2.Checked = True Then
            Try
                Dim framea As String = TrackBar1.Value
                If framea < 100 Then
                    framea = "0" & TrackBar1.Value
                End If
                If framea < 10 Then
                    framea = "00" & TrackBar1.Value
                End If
                PictureBox1.Image = System.Drawing.Bitmap.FromFile(TextBox2.Text & "\Renderdpic_" & framea & ".png")
                Timer1.Enabled = False
            Catch ex As Exception
            End Try
        End If
        Dim currentframe As Integer = TrackBar3.Value
        Dim frame As String = currentframe
        If CheckBox1.Checked = True Then
            frame = currentframe
            If frame < 100 Then
                frame = "0" & currentframe
            End If
            If frame < 10 Then
                frame = "00" & currentframe
            End If
            Try
                PictureBox1.Image = System.Drawing.Bitmap.FromFile(TextBox2.Text & "\Renderdpic_" & frame & ".png")
                currentframe = currentframe + 1
            Catch ex As Exception

            End Try
        End If
    End Sub
    Sub download(myLink As String, myFile As String)
        Try
            Me.Text = "Downloading..."
            Label1.Text = "Downloading..."
            Dim myRequest As System.Net.WebRequest = System.Net.WebRequest.Create(myLink)
            Dim myResponse As System.Net.WebResponse = myRequest.GetResponse()
            Dim myStream As System.IO.Stream = myResponse.GetResponseStream()
            Dim myReader As New System.IO.BinaryReader(myStream)
            Dim myFileStream As New System.IO.FileStream(myFile, System.IO.FileMode.Create)
            Dim i As Long
            ProgressBar1.Maximum = myResponse.ContentLength
            ProgressBar1.Value = 0
            For i = 1 To myResponse.ContentLength
                myFileStream.WriteByte(myReader.ReadByte())
                If ProgressBar1.Value + 1 < ProgressBar1.Maximum Then
                    ProgressBar1.Value = ProgressBar1.Value + 1
                End If
            Next i
            myFileStream.Flush()
            myFileStream.Close()
            MsgBox("Downloaded")
            Me.Text = "Finished downloading"
            MsgBox("Starting to unpack now...")
            Me.Text = "Unpacking..."
            Label1.Text = "Unpacking..."
            System.IO.Compression.ZipFile.ExtractToDirectory(appdata & "\BV\" & ComboBox1.SelectedItem & ".zip", appdata & "\BV_R\")
            MsgBox("Unpacked Blender-Version " & ComboBox1.SelectedItem & "! Now ready to use")
            My.Computer.FileSystem.WriteAllText(appdata & "\DownloadedVersions.txt",
           ComboBox1.SelectedItem & vbCrLf, True)
            Me.Hide()
        Catch ex As Exception
            MsgBox("Error:  " & ex.Message)
        End Try
    End Sub
End Class