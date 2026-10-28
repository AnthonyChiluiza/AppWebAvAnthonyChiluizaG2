using System;
using System.Configuration;
using System.Data;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebAppPoliMusicV2
{
    public partial class Song : System.Web.UI.Page
    {
        private string strConnString = ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            Entities.User user = GetAuthenticatedUser();
            if (user == null)
            {
                Response.Redirect("Login.aspx", true);
                return;
            }
            ShowAuthenticatedUser(user);

            if (!Page.IsPostBack)
            {
                BindSongs(string.Empty);
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindSongs(txtSearch.Text);
        }

        /// <summary>
        /// Recupera el usuario autenticado desde la sesion y, si la sesion
        /// expiro, desde la cookie de Forms Authentication.
        /// </summary>
        private Entities.User GetAuthenticatedUser()
        {
            Entities.User user = Session[Util.Constants.USER] as Entities.User;
            if (user == null && Context.User != null && Context.User.Identity.IsAuthenticated)
            {
                user = new Entities.User();
                user.UserName = Context.User.Identity.Name;
                user.Photo = string.Empty;
                user.UserType = Util.Constants.ID_USER_NORMAL;
            }
            return user;
        }

        /// <summary>
        /// Muestra en pantalla el nombre del usuario autenticado, su rol y su foto.
        /// </summary>
        private void ShowAuthenticatedUser(Entities.User user)
        {
            string userName = string.IsNullOrEmpty(user.UserName) ? "Invitado" : user.UserName;

            litUserName.Text = H(userName);
            litGreetingName.Text = H(userName);
            litUserType.Text = (user.UserType == Util.Constants.ID_USER_ADMIN) ? "Administrador" : "Usuario";

            string photo = user.Photo;
            if (!string.IsNullOrEmpty(photo))
            {
                try
                {
                    if (File.Exists(Server.MapPath(photo)))
                    {
                        litAvatar.Text = "<img class=\"avatar-photo\" src=\"" + ResolveUrl(photo) + "\" alt=\"" + H(userName) + "\" />";
                        return;
                    }
                }
                catch (Exception)
                {
                    // Si la ruta de la foto no es valida se usa la inicial del usuario.
                }
            }

            string initial = (userName.Length > 0) ? userName.Substring(0, 1).ToUpper() : "?";
            litAvatar.Text = "<span class=\"avatar-initial\">" + H(initial) + "</span>";
        }

        /// <summary>
        /// Llena la lista de canciones usando la capa de logica de negocio.
        /// </summary>
        private void BindSongs(string criteria)
        {
            lblMessage.Text = string.Empty;
            string search = (criteria == null) ? string.Empty : criteria.Trim();

            try
            {
                BLL.Song bllSong = new BLL.Song(strConnString);
                DataTable dtSongs = (search.Length == 0) ? bllSong.Read() : bllSong.SearchByName(search);

                rptSongs.DataSource = dtSongs;
                rptSongs.DataBind();

                bool hasSongs = dtSongs.Rows.Count > 0;
                pnlList.Visible = hasSongs;
                pnlEmpty.Visible = !hasSongs;

                litResultCount.Text = dtSongs.Rows.Count.ToString() +
                    (dtSongs.Rows.Count == 1 ? " canción" : " canciones");

                LoadStatistics(bllSong);
            }
            catch (Exception ex)
            {
                pnlList.Visible = false;
                pnlEmpty.Visible = false;
                litResultCount.Text = "0 canciones";
                lblMessage.Text = Server.HtmlEncode("No se pudo cargar el catálogo: " + ex.Message);
            }
        }

        /// <summary>
        /// Totales del catalogo (canciones y reproducciones) para el encabezado.
        /// </summary>
        private void LoadStatistics(BLL.Song bllSong)
        {
            int totalSongs = 0;
            int totalPlays = 0;

            DataTable dtStatistics = bllSong.ReadStatistics();
            if (dtStatistics != null && dtStatistics.Rows.Count > 0)
            {
                totalSongs = N(dtStatistics.Rows[0]["TOTAL_SONGS"]);
                totalPlays = N(dtStatistics.Rows[0]["TOTAL_PLAYS"]);
            }

            litTotalSongs.Text = totalSongs.ToString();
            litTotalPlays.Text = totalPlays.ToString("N0");
        }

        /// <summary>
        /// Convierte una ruta tipo "~/songFiles/x.mp3" en una URL valida para el navegador.
        /// </summary>
        protected string SongUrl(object path)
        {
            string value = Convert.ToString(path);
            if (string.IsNullOrEmpty(value))
            {
                return string.Empty;
            }
            return ResolveUrl(value);
        }

        /// <summary>
        /// Nombre del archivo de audio (ultimo segmento de SONG_PATH).
        /// </summary>
        protected string FileName(object path)
        {
            string value = Convert.ToString(path);
            if (string.IsNullOrEmpty(value))
            {
                return string.Empty;
            }
            int index = value.LastIndexOfAny(new char[] { '/', '\\' });
            return H(index >= 0 ? value.Substring(index + 1) : value);
        }

        /// <summary>
        /// Primera letra del nombre, usada como caratula de la cancion.
        /// </summary>
        protected string Initial(object value)
        {
            string text = Convert.ToString(value);
            if (string.IsNullOrEmpty(text))
            {
                return "♪";
            }
            return H(text.Substring(0, 1).ToUpper());
        }

        /// <summary>
        /// Convierte un valor de la base de datos en entero, controlando DBNull.
        /// </summary>
        protected int N(object value)
        {
            if (value == null || value == DBNull.Value)
            {
                return 0;
            }
            return Convert.ToInt32(value);
        }

        /// <summary>
        /// Codifica el texto antes de escribirlo en el HTML.
        /// </summary>
        protected string H(object value)
        {
            return HttpUtility.HtmlEncode(Convert.ToString(value));
        }
    }

}
