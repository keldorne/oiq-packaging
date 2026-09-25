# Guide pour Xavier : publier une mise a jour de l'app OIQ

Ce depot (`oiq-packaging`) contient uniquement l'**emballage** de ton
application (installeurs Windows/Linux, scripts de build). Ton code source
lui-meme n'y est jamais modifie : a chaque construction, le script va le
chercher directement a l'URL de ton zip sur leblogaudiologie.com.

Ce guide explique comment publier une nouvelle version des installeurs
quand tu mets a jour ton app, **sans avoir a refaire toi-meme** toute
l'installation R/Python/compilateurs/etc. — c'est le role de ce depot.

## 1. Creer un compte GitHub (une seule fois)

1. Va sur https://github.com/signup et cree un compte (gratuit) avec ton
   adresse email habituelle.
2. Verifie ton adresse email (lien recu par mail) — c'est necessaire pour
   que les constructions automatiques fonctionnent.
3. Donne-moi (Kevin) le nom d'utilisateur que tu as choisi : je
   t'ajouterai comme collaborateur sur https://github.com/keldorne/oiq-packaging,
   ce qui te permettra de pousser des mises a jour.

## 2. Installer Git sur ta machine (une seule fois)

- **Windows** : telecharge et installe https://git-scm.com/download/win
  (options par defaut, "Suivant" partout).
- Une fois installe, ouvre "Git Bash" (installe avec Git) — c'est le
  terminal a utiliser pour les commandes ci-dessous.

Puis configure ton identite (remplace par tes vraies infos) :
```bash
git config --global user.name "Xavier Delerce"
git config --global user.email "ton-email@exemple.com"
```

## 3. Recuperer le depot sur ta machine (une seule fois)

```bash
git clone https://github.com/keldorne/oiq-packaging.git
cd oiq-packaging
```
Git va te demander de te connecter avec ton compte GitHub (une fenetre
s'ouvre dans le navigateur, tu autorises l'acces) — c'est normal, une
seule fois.

## 4. A chaque fois que tu mets a jour ton app

**Tu n'as rien a faire dans ce depot pour le code de l'app lui-meme** —
il est toujours recupere automatiquement depuis ton zip en ligne a chaque
construction. Il te suffit de **demander une nouvelle version des
installeurs** en creant une "etiquette" (tag) qui declenche la
construction automatique :

```bash
cd oiq-packaging
git pull                       # recupere les derniers scripts si besoin
git tag v1.1.0                 # choisis un numero de version qui suit le precedent
git push origin v1.1.0
```

C'est tout. Ca declenche automatiquement, sur les serveurs de GitHub
(gratuit, rien a installer chez toi) :
- La construction de l'installeur Windows (`.exe`)
- La construction de l'installeur Linux (`.run`)
- La creation d'une "release" GitHub en **brouillon**, avec les deux
  fichiers en piece jointe — rien n'est visible publiquement tant que
  quelqu'un ne clique pas sur "Publier" dans l'interface GitHub.

## 5. Suivre la construction

Va sur https://github.com/keldorne/oiq-packaging/actions — tu verras la
construction en cours (Linux + Windows), avec le detail de chaque etape.
Ca prend environ 10 a 20 minutes. Une fois termine, va dans l'onglet
"Releases" du depot pour recuperer les fichiers et les tester avant de
publier.

## 6. Si tu modifies un script de packaging (rare)

Si tu veux changer un des scripts de ce depot (par exemple
`launcher/oiq.sh`, `installer/windows/oiq.iss`...) — a la difference de
ton propre code applicatif, ces fichiers vivent dans ce depot et se
modifient avec Git classique :
```bash
git add <fichier-modifie>
git commit -m "Description courte de ce que tu as change"
git push origin master
```

## Question / probleme

Contacte Kevin — c'est lui qui a construit et maintient ce pipeline.
