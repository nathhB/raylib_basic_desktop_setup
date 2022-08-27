# raylib_basic_desktop_setup
Un setup de base pour compiler des applications raylib desktop (fonctionne avec Windows, OSX et Linux).

Ouvrez votre shell préféré et suivez ces instructions:

1. Clonez le repo

`git clone https://github.com/nathhB/raylib_basic_desktop_setup.git`

2. Clonez le submodule raylib

Rendez-vous à la racine du repo fraichement cloné et tapez les commandes suivantes:

`git submodule init`

`git submodule update`

3. Compilez raylib

Rendez-vous dans le dossier *raylib* et référez-vous aux instructions de compilation relatives à votre système d'exploitation:
- [Windows](https://github.com/raysan5/raylib/wiki/Working-on-Windows)
- [Linux](https://github.com/raysan5/raylib/wiki/Working-on-GNU-Linux)
- [OSX](https://github.com/raysan5/raylib/wiki/Working-on-macOS)

3. Compilez le programme

Tapez la commande `make` pour compiler le programme et `./basic_raylib` pour l'exécuter.
