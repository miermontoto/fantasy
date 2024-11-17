# fantasy
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
para ejecutar el comando, es necesario tener un archivo `.env` en la raíz del
proyecto con las siguientes variables de entorno:
```bash
REFRESH=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

la variable `REFRESH` es necesaria para la autenticación en la
API de Fantasy MARCA. para obtenerla, sigue los siguientes pasos:
1. inicia sesión en la página de [Fantasy MARCA](https://fantasy.marca.com/)
2. abre la consola del navegador y ve a la pestaña de `Storage`
3. copia el valor de la cookie `refresh_token` y pégalo en el archivo `.env` como
   el valor de la variable `REFRESH`

### uso
el comando de ejecución es `main.rb` y acepta las siguientes opciones:
```
Usage: ruby main.rb [endpoint]
	feed: muestra la información de la página principal (por defecto)
	market: muestra la información de los jugadores disponibles en el mercado
	team: muestra la información de tu equipo
	standings: muestra la clasificación de la liga (global y jornada)
```

## desarrollo
el proyecto está estructurado de la siguiente manera:
```
fantasy
├── .env
├── .gitignore
├── Gemfile
├── Gemfile.lock
├── README.md
├── main.rb
├── token.rb
├── lib
│   ├── browser.rb
│   ├── scraper.rb
│   └── helpers.rb
└── models
	├── transfer.rb
	├── player.rb
	├── position.rb
	└── user.rb
```
