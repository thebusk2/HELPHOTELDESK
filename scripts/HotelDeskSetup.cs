using System;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.IO.Compression;
using System.Net;
using System.Text.RegularExpressions;
using System.Threading;
using System.Windows.Forms;

namespace HotelDeskInstaller
{
    public class MainForm : Form
    {
        private ProgressBar progressBar;
        private Label lblStatus;
        private TextBox txtLog;
        private TextBox txtHotelName;
        private TextBox txtAdminEmail;
        private Button btnStart;
        private Button btnOpenWeb;
        private Panel headerPanel;

        [STAThread]
        public static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new MainForm());
        }

        public MainForm()
        {
            InitializeComponent();
        }

        private void InitializeComponent()
        {
            this.Text = "HELPHOTELDESK - Sistema de Mesa de Ayuda Hotelera";
            this.Size = new Size(680, 580);
            this.StartPosition = FormStartPosition.CenterScreen;
            this.FormBorderStyle = FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
            this.BackColor = Color.FromArgb(245, 247, 250);

            try
            {
                string iconFile = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "assets", "app.ico");
                if (File.Exists(iconFile))
                {
                    this.Icon = new Icon(iconFile);
                }
            }
            catch { }

            // Header
            headerPanel = new Panel();
            headerPanel.Size = new Size(680, 75);
            headerPanel.BackColor = Color.FromArgb(24, 43, 73);
            this.Controls.Add(headerPanel);

            Label lblTitle = new Label();
            lblTitle.Text = "🏨 HELPHOTELDESK - INSTALADOR INTEGRAL";
            lblTitle.Font = new Font("Segoe UI", 13, FontStyle.Bold);
            lblTitle.ForeColor = Color.White;
            lblTitle.Location = new Point(20, 15);
            lblTitle.AutoSize = true;
            headerPanel.Controls.Add(lblTitle);

            Label lblSub = new Label();
            lblSub.Text = "Mesa de Ayuda & Control de Activos TI para Hoteles (Windows 10 Hyper-V)";
            lblSub.Font = new Font("Segoe UI", 8.5f);
            lblSub.ForeColor = Color.LightGray;
            lblSub.Location = new Point(22, 42);
            lblSub.AutoSize = true;
            headerPanel.Controls.Add(lblSub);

            // Config Box
            GroupBox grpConfig = new GroupBox();
            grpConfig.Text = " 1. Personalización del Hotel ";
            grpConfig.Font = new Font("Segoe UI", 9, FontStyle.Bold);
            grpConfig.Location = new Point(20, 85);
            grpConfig.Size = new Size(625, 95);
            this.Controls.Add(grpConfig);

            Label lblHName = new Label();
            lblHName.Text = "Nombre del Hotel / Cadena:";
            lblHName.Font = new Font("Segoe UI", 8.5f);
            lblHName.Location = new Point(20, 25);
            lblHName.AutoSize = true;
            grpConfig.Controls.Add(lblHName);

            txtHotelName = new TextBox();
            txtHotelName.Text = "Gran Hotel Resort & Spa";
            txtHotelName.Font = new Font("Segoe UI", 9);
            txtHotelName.Location = new Point(20, 48);
            txtHotelName.Size = new Size(270, 25);
            grpConfig.Controls.Add(txtHotelName);

            Label lblEmail = new Label();
            lblEmail.Text = "Correo Soporte TI (Mesa de Ayuda):";
            lblEmail.Font = new Font("Segoe UI", 8.5f);
            lblEmail.Location = new Point(320, 25);
            lblEmail.AutoSize = true;
            grpConfig.Controls.Add(lblEmail);

            txtAdminEmail = new TextBox();
            txtAdminEmail.Text = "informatica@hotel.com";
            txtAdminEmail.Font = new Font("Segoe UI", 9);
            txtAdminEmail.Location = new Point(320, 48);
            txtAdminEmail.Size = new Size(270, 25);
            grpConfig.Controls.Add(txtAdminEmail);

            // Installation Progress
            GroupBox grpProgress = new GroupBox();
            grpProgress.Text = " 2. Despliegue de Servidor Local & Mesa de Ayuda ";
            grpProgress.Font = new Font("Segoe UI", 9, FontStyle.Bold);
            grpProgress.Location = new Point(20, 190);
            grpProgress.Size = new Size(625, 270);
            this.Controls.Add(grpProgress);

            lblStatus = new Label();
            lblStatus.Text = "Listo para comenzar la instalación.";
            lblStatus.Font = new Font("Segoe UI", 8.5f);
            lblStatus.Location = new Point(20, 25);
            lblStatus.Size = new Size(570, 20);
            grpProgress.Controls.Add(lblStatus);

            progressBar = new ProgressBar();
            progressBar.Location = new Point(20, 48);
            progressBar.Size = new Size(580, 22);
            grpProgress.Controls.Add(progressBar);

            txtLog = new TextBox();
            txtLog.Multiline = true;
            txtLog.ScrollBars = ScrollBars.Vertical;
            txtLog.ReadOnly = true;
            txtLog.BackColor = Color.FromArgb(20, 24, 30);
            txtLog.ForeColor = Color.FromArgb(220, 225, 230);
            txtLog.Font = new Font("Consolas", 8.5f);
            txtLog.Location = new Point(20, 80);
            txtLog.Size = new Size(580, 175);
            grpProgress.Controls.Add(txtLog);

            // Action Buttons
            btnStart = new Button();
            btnStart.Text = "🚀 Iniciar Instalación Completa";
            btnStart.Font = new Font("Segoe UI", 9.5f, FontStyle.Bold);
            btnStart.BackColor = Color.FromArgb(41, 128, 185);
            btnStart.ForeColor = Color.White;
            btnStart.FlatStyle = FlatStyle.Flat;
            btnStart.Location = new Point(20, 475);
            btnStart.Size = new Size(230, 45);
            btnStart.Click += new EventHandler(BtnStart_Click);
            this.Controls.Add(btnStart);

            btnOpenWeb = new Button();
            btnOpenWeb.Text = "🌐 Abrir Mesa de Ayuda";
            btnOpenWeb.Font = new Font("Segoe UI", 9.5f, FontStyle.Bold);
            btnOpenWeb.BackColor = Color.FromArgb(46, 204, 113);
            btnOpenWeb.ForeColor = Color.White;
            btnOpenWeb.FlatStyle = FlatStyle.Flat;
            btnOpenWeb.Location = new Point(415, 475);
            btnOpenWeb.Size = new Size(230, 45);
            btnOpenWeb.Enabled = false;
            btnOpenWeb.Click += (s, e) => Process.Start("http://localhost/glpi");
            // Pie de página con créditos del autor
            Label lblFooter = new Label();
            lblFooter.Text = "HELPHOTELDESK Suite • Creado por Andy Robles (@thebusk2)";
            lblFooter.Font = new Font("Segoe UI", 8.2f, FontStyle.Italic);
            lblFooter.ForeColor = Color.FromArgb(120, 130, 145);
            lblFooter.Location = new Point(20, 526);
            lblFooter.AutoSize = true;
            this.Controls.Add(lblFooter);

            LinkLabel lnkGitHub = new LinkLabel();
            lnkGitHub.Text = "github.com/thebusk2/HELPHOTELDESK";
            lnkGitHub.Font = new Font("Segoe UI", 8.2f);
            lnkGitHub.Location = new Point(415, 526);
            lnkGitHub.AutoSize = true;
            lnkGitHub.LinkClicked += (s, e) => Process.Start("https://github.com/thebusk2/HELPHOTELDESK");
            this.Controls.Add(lnkGitHub);
        }

        private void Log(string message)
        {
            if (this.InvokeRequired)
            {
                this.Invoke(new Action<string>(Log), message);
                return;
            }
            txtLog.AppendText(string.Format("[{0}] {1}\r\n", DateTime.Now.ToString("HH:mm:ss"), message));
        }

        private void UpdateProgress(int value, string status)
        {
            if (this.InvokeRequired)
            {
                this.Invoke(new Action<int, string>(UpdateProgress), value, status);
                return;
            }
            progressBar.Value = value;
            lblStatus.Text = status;
        }

        private void BtnStart_Click(object sender, EventArgs e)
        {
            btnStart.Enabled = false;
            txtHotelName.Enabled = false;
            txtAdminEmail.Enabled = false;

            Thread worker = new Thread(DoInstallation);
            worker.IsBackground = true;
            worker.Start();
        }

        private void DoInstallation()
        {
            try
            {
                UpdateProgress(5, "Configurando Firewall de Windows...");
                Log("Abriendo puertos 80 (HTTP) y 443 (HTTPS) en el Firewall de Windows...");
                RunProcess("netsh", "advfirewall firewall add rule name=\"HotelDesk HTTP\" dir=in action=allow protocol=TCP localport=80");
                RunProcess("netsh", "advfirewall firewall add rule name=\"HotelDesk HTTPS\" dir=in action=allow protocol=TCP localport=443");

                // Guardar configuración inicial
                UpdateProgress(15, "Guardando configuración de identidad hotelera...");
                string hotelDir = @"C:\HotelDesk";
                if (!Directory.Exists(hotelDir)) Directory.CreateDirectory(hotelDir);

                string configJson = string.Format("{{\"HotelName\": \"{0}\", \"SupportEmail\": \"{1}\"}}", txtHotelName.Text, txtAdminEmail.Text);
                File.WriteAllText(Path.Combine(hotelDir, "hotel_config.json"), configJson);
                Log("Configuración de hotel guardada.");

                // Descargar e instalar XAMPP
                UpdateProgress(25, "Descargando entorno servidor (Apache + PHP 8.2 + MariaDB)...");
                string tempDir = Path.GetTempPath();
                string xamppInstaller = Path.Combine(tempDir, "xampp-installer.exe");

                if (!File.Exists(@"C:\xampp\apache\bin\httpd.exe"))
                {
                    Log("Descargando componentes de servidor XAMPP...");
                    using (WebClient client = new WebClient())
                    {
                        ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
                        client.DownloadFile("https://sourceforge.net/projects/xampp/files/XAMPP%20Windows/8.2.12/xampp-windows-x64-8.2.12-0-VS16-installer.exe/download", xamppInstaller);
                    }
                    Log("Instalando servidor en C:\\xampp de forma desatendida...");
                    UpdateProgress(40, "Instalando servidor local en segundo plano...");
                    RunProcess(xamppInstaller, "--mode unattended");
                }
                else
                {
                    Log("XAMPP ya está instalado en el sistema.");
                }

                // Descargar GLPI
                UpdateProgress(60, "Descargando GLPI Helpdesk v10...");
                string glpiZip = Path.Combine(tempDir, "glpi.tgz");
                if (!Directory.Exists(@"C:\xampp\htdocs\glpi"))
                {
                    Log("Descargando paquete oficial de GLPI...");
                    using (WebClient client = new WebClient())
                    {
                        ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
                        client.DownloadFile("https://github.com/glpi-project/glpi/releases/download/10.0.16/glpi-10.0.16.tgz", glpiZip);
                    }

                    Log("Extrayendo archivos de la mesa de ayuda en C:\\xampp\\htdocs\\glpi...");
                    UpdateProgress(75, "Extrayendo archivos de GLPI...");
                    RunProcess("tar", string.Format("-xzf \"{0}\" -C \"C:\\xampp\\htdocs\"", glpiZip));
                }
                else
                {
                    Log("GLPI ya existe en C:\\xampp\\htdocs\\glpi.");
                }

                // Habilitar extensiones PHP
                UpdateProgress(85, "Optimizando configuración de PHP para Hotelería...");
                string phpIni = @"C:\xampp\php\php.ini";
                if (File.Exists(phpIni))
                {
                    string iniContent = File.ReadAllText(phpIni);
                    string[] exts = new string[] { "curl", "fileinfo", "gd", "intl", "mbstring", "mysqli", "openssl", "pdo_mysql", "soap", "sockets", "sodium", "zip", "ldap", "bz2" };
                    foreach (string ext in exts)
                    {
                        iniContent = iniContent.Replace(";extension=" + ext, "extension=" + ext);
                    }
                    iniContent = iniContent.Replace("upload_max_filesize = 2M", "upload_max_filesize = 32M");
                    iniContent = iniContent.Replace("post_max_size = 8M", "post_max_size = 48M");
                    File.WriteAllText(phpIni, iniContent);
                    Log("Extensiones PHP (intl, ldap, gd, zip, mysqli) habilitadas con éxito.");
                }

                // Iniciar servicios
                UpdateProgress(95, "Iniciando servicios de Apache y MariaDB...");
                if (File.Exists(@"C:\xampp\xampp_start.exe"))
                {
                    RunProcess(@"C:\xampp\xampp_start.exe", "");
                }

                UpdateProgress(100, "¡Instalación completada con éxito!");
                Log("¡Servidor listo! La mesa de ayuda está operando.");
                Log("URL Local: http://localhost/glpi");

                this.Invoke(new Action(() => {
                    btnOpenWeb.Enabled = true;
                    MessageBox.Show("La instalación de la Mesa de Ayuda para el Hotel se completó con éxito.\n\nHaz clic en 'Abrir Mesa de Ayuda' para acceder.", "Instalación Finalizada", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }));
            }
            catch (Exception ex)
            {
                Log("ERROR: " + ex.Message);
                UpdateProgress(0, "Ocurrió un problema durante la instalación.");
                this.Invoke(new Action(() => {
                    btnStart.Enabled = true;
                    MessageBox.Show("Error: " + ex.Message, "Fallo de Instalación", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }));
            }
        }

        private void RunProcess(string exe, string args)
        {
            ProcessStartInfo psi = new ProcessStartInfo(exe, args);
            psi.CreateNoWindow = true;
            psi.UseShellExecute = false;
            psi.WindowStyle = ProcessWindowStyle.Hidden;
            using (Process p = Process.Start(psi))
            {
                p.WaitForExit();
            }
        }
    }
}
