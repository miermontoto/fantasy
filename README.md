# fantasy

> [!WARNING]
> Este repo es funcional pero está desactualizado para la temporada 25/26.
> Las funcionalidades principales (deltas de equipos, más clausulados, etc.),
> están ya presentes en el webview de Marca.

herramienta CLI hecha en Ruby para acceder y analizar datos del webgame
[Fantasy MARCA](https://fantasy.marca.com/) para cualquiera de las ligas
disponibles.

## instalación

para instalar el scraper, clona el repositorio e instala las dependencias con
bundler.

```bash
git clone https://github.com/miermontoto/fantasy
bundle install
```

las gemas dependientes se encuentans en el archivo [`Gemfile`](Gemfile).

### preparación

para ejecutar el comando, es necesario configurar correctamente un fichero
`tokens.json` en la raíz del proyecto con las siguientes variables de entorno:

```json
{
  "current_community": 0,
  "refresh": "your_refresh_token",
  "xauth": {
    "community_id": "xauth_token_for_this_community",
    "community_id_2": "xauth_token_for_this_community"
  }
}
```

para obtener los tokens, sigue los siguientes pasos:

1. inicia sesión en la página de [Fantasy MARCA](https://fantasy.marca.com/)
2. abre la consola del navegador y ve a la pestaña de `Storage`
3. copia el valor de la cookie `refresh_token` y pégalo en el archivo `.env` como
   el valor de la variable `REFRESH`
4. copia el valor de la cookie `xauth_token` y pégalo en el archivo `.env` como
   el valor de la variable `XAUTH` para cada una de las ligas que quieras
   analizar.

### script

el comando de ejecución es `main.rb` y acepta las siguientes opciones:

```plaintext
Usage: ruby main.rb [endpoint]
 feed: muestra la información de la página principal (por defecto)
 market: muestra la información de los jugadores disponibles en el mercado
 team: muestra la información de tu equipo
 standings: muestra la clasificación de la liga (global y jornada)
```

### web

para ejecutar el servicio webview de rails, ejecuta el siguiente comando:

```bash
rails tailwindcss:build && rails s -b 0.0.0.0
```
