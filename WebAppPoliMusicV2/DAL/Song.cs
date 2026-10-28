using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web;

namespace WebAppPoliMusicV2.DAL
{
    /// <summary>
    /// Capa de acceso a datos de la tabla TBL_SONG.
    /// Todas las sentencias usan parametros para evitar inyeccion SQL.
    /// </summary>
    public class Song
    {
        private string strConnectionString;

        // Columnas que se devuelven en las consultas de lectura.
        // PLAYS admite NULL en la base de datos, por eso se normaliza a 0.
        private const string COLUMNS = "[ID_SONG], [SONG_NAME], [SONG_PATH], ISNULL([PLAYS], 0) AS [PLAYS]";

        public Song(string strConnString)
        {
            strConnectionString = strConnString;
        }

        /// <summary>
        /// Inserta una cancion. Devuelve el numero de filas afectadas.
        /// </summary>
        public int Save(Entities.Song song)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "INSERT INTO [TBL_SONG] ([SONG_NAME], [SONG_PATH], [PLAYS]) " +
                                      "VALUES (@SONG_NAME, @SONG_PATH, @PLAYS)";
                    cmd.Parameters.AddWithValue("@SONG_NAME", song.SongName);
                    cmd.Parameters.AddWithValue("@SONG_PATH", song.SongPath);
                    cmd.Parameters.AddWithValue("@PLAYS", song.Plays);
                    cmd.Connection = con;
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Devuelve todas las canciones ordenadas por nombre.
        /// </summary>
        public DataTable Read()
        {
            DataTable dtSong = new DataTable();
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT " + COLUMNS + " FROM [TBL_SONG] ORDER BY [SONG_NAME]", con))
                {
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        sda.Fill(dtSong);
                        return dtSong;
                    }
                }
            }
        }

        /// <summary>
        /// Devuelve una cancion por su identificador.
        /// </summary>
        public DataTable ReadById(int idSong)
        {
            DataTable dtSong = new DataTable();
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT " + COLUMNS + " FROM [TBL_SONG] WHERE [ID_SONG] = @ID_SONG", con))
                {
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        sda.Fill(dtSong);
                        return dtSong;
                    }
                }
            }
        }

        /// <summary>
        /// Busca canciones cuyo nombre contenga el criterio recibido.
        /// Los comodines de LIKE escritos por el usuario se escapan.
        /// </summary>
        public DataTable SearchByName(string criteria)
        {
            DataTable dtSong = new DataTable();
            string strCriteria = (criteria == null) ? string.Empty : criteria.Trim();
            string strPattern = "%" + strCriteria.Replace("[", "[[]").Replace("%", "[%]").Replace("_", "[_]") + "%";
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT " + COLUMNS + " FROM [TBL_SONG] WHERE [SONG_NAME] LIKE @SONG_NAME ORDER BY [SONG_NAME]", con))
                {
                    cmd.Parameters.AddWithValue("@SONG_NAME", strPattern);
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        sda.Fill(dtSong);
                        return dtSong;
                    }
                }
            }
        }

        /// <summary>
        /// Devuelve el total de canciones y el total de reproducciones del catalogo.
        /// </summary>
        public DataTable ReadStatistics()
        {
            DataTable dtStatistics = new DataTable();
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) AS [TOTAL_SONGS], " +
                                                       "ISNULL(SUM(ISNULL([PLAYS], 0)), 0) AS [TOTAL_PLAYS] " +
                                                       "FROM [TBL_SONG]", con))
                {
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        sda.Fill(dtStatistics);
                        return dtStatistics;
                    }
                }
            }
        }

        /// <summary>
        /// Actualiza el nombre, la ruta y las reproducciones de una cancion.
        /// </summary>
        public int Update(Entities.Song song)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "UPDATE [TBL_SONG] SET " +
                                      "[SONG_NAME] = @SONG_NAME, " +
                                      "[SONG_PATH] = @SONG_PATH, " +
                                      "[PLAYS] = @PLAYS " +
                                      "WHERE [ID_SONG] = @ID_SONG";
                    cmd.Parameters.AddWithValue("@ID_SONG", song.ID);
                    cmd.Parameters.AddWithValue("@SONG_NAME", song.SongName);
                    cmd.Parameters.AddWithValue("@SONG_PATH", song.SongPath);
                    cmd.Parameters.AddWithValue("@PLAYS", song.Plays);
                    cmd.Connection = con;
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Elimina una cancion por su identificador.
        /// </summary>
        public int Delete(int idSong)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "DELETE FROM [TBL_SONG] WHERE [ID_SONG] = @ID_SONG";
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    cmd.Connection = con;
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Incrementa en uno el contador PLAYS de una cancion.
        /// </summary>
        public int IncrementPlays(int idSong)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "UPDATE [TBL_SONG] SET [PLAYS] = ISNULL([PLAYS], 0) + 1 WHERE [ID_SONG] = @ID_SONG";
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    cmd.Connection = con;
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Comprueba si el nombre de la cancion ya existe. Devuelve 0 si no existe.
        /// </summary>
        public int CheckExistSong(string songName)
        {
            object returnValue;
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.CommandText = "SELECT [ID_SONG] FROM [TBL_SONG] WHERE [SONG_NAME] = @SONG_NAME";
                    cmd.Parameters.AddWithValue("@SONG_NAME", songName);
                    cmd.Connection = con;
                    con.Open();
                    returnValue = cmd.ExecuteScalar();
                    return (returnValue == null) ? 0 : Convert.ToInt32(returnValue);
                }
            }
        }
    }


}
