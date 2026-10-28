using System;
using System.Collections.Generic;
using System.Data;
using System.Web;

namespace WebAppPoliMusicV2.BLL
{
    /// <summary>
    /// Capa de logica de negocio de la entidad Song.
    /// Delega el acceso a datos en DAL.Song y agrega las validaciones.
    /// </summary>
    public class Song
    {
        private string strConnectionString;

        public Song(string strConnString)
        {
            strConnectionString = strConnString;
        }

        public int Save(Entities.Song song)
        {
            return new DAL.Song(strConnectionString).Save(song);
        }

        public DataTable Read()
        {
            return new DAL.Song(strConnectionString).Read();
        }

        public DataTable ReadById(int idSong)
        {
            return new DAL.Song(strConnectionString).ReadById(idSong);
        }

        public DataTable SearchByName(string criteria)
        {
            return new DAL.Song(strConnectionString).SearchByName(criteria);
        }

        public DataTable ReadStatistics()
        {
            return new DAL.Song(strConnectionString).ReadStatistics();
        }

        public int Update(Entities.Song song)
        {
            return new DAL.Song(strConnectionString).Update(song);
        }

        public int Delete(int idSong)
        {
            return new DAL.Song(strConnectionString).Delete(idSong);
        }

        public int IncrementPlays(int idSong)
        {
            return new DAL.Song(strConnectionString).IncrementPlays(idSong);
        }

        public int CheckExistSong(string songName)
        {
            return new DAL.Song(strConnectionString).CheckExistSong(songName);
        }

        /// <summary>
        /// Valida los datos de una cancion antes de guardarla.
        /// Devuelve una cadena vacia cuando todo es correcto.
        /// </summary>
        public string Validations(Entities.Song song)
        {
            if (song == null)
            {
                return "La informacion de la cancion es obligatoria.";
            }
            if (string.IsNullOrEmpty(song.SongName))
            {
                return "El nombre de la cancion es obligatorio.";
            }
            if (song.SongName.Trim().Length > 50)
            {
                return "El nombre de la cancion no puede superar los 50 caracteres.";
            }
            if (string.IsNullOrEmpty(song.SongPath))
            {
                return "La ruta del archivo de audio es obligatoria.";
            }
            if (song.SongPath.Trim().Length > 255)
            {
                return "La ruta del archivo no puede superar los 255 caracteres.";
            }
            if (song.Plays < 0)
            {
                return "El numero de reproducciones no puede ser negativo.";
            }
            if (CheckExistSong(song.SongName.Trim()) != 0)
            {
                return "Ya existe una cancion registrada con ese nombre.";
            }
            return string.Empty;
        }
    }


}
