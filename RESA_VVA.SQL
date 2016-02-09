DROP DATABASE IF EXISTS RESA_VVA;

CREATE DATABASE IF NOT EXISTS RESA_VVA;
USE RESA_VVA;
# -----------------------------------------------------------------------------
#       TABLE : ETAT_RESA
# -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS ETAT_RESA
 (
   CODEETATRESA CHAR(2) NOT NULL  ,
   NOMETATRESA CHAR(15) NULL  
   , PRIMARY KEY (CODEETATRESA) 
 ) 
 comment = "";

# -----------------------------------------------------------------------------
#       TABLE : HEBERGEMENT
# -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS HEBERGEMENT
 (
   NOHEB INTEGER(4) NOT NULL  ,
   CODETYPEHEB CHAR(5) NOT NULL  ,
   NOMHEB CHAR(25) NULL  ,
   NBPLACEHEB INTEGER(2) NULL  ,
   SURFACEHEB INTEGER(2) NULL  ,
   INTERNET BOOL NULL  ,
   ANNEEHEB INTEGER(4) NULL  ,
   SECTEURHEB CHAR(15) NULL  ,
   ORIENTATIONHEB CHAR(5) NULL  ,
   ETATHEB CHAR(32) NULL  ,
   DESCRIHEB CHAR(200) NULL  ,
   PHOTOHEB CHAR(50) NULL  
   , PRIMARY KEY (NOHEB) 
 ) 
 comment = "";

# -----------------------------------------------------------------------------
#       INDEX DE LA TABLE HEBERGEMENT
# -----------------------------------------------------------------------------


CREATE  INDEX I_FK_HEBERGEMENT_TYPE_HEB
     ON HEBERGEMENT (CODETYPEHEB ASC);

# -----------------------------------------------------------------------------
#       TABLE : SAISON
# -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS SAISON
 (
   CODESAISON CHAR(2) NOT NULL  ,
   NOMSAISON CHAR(15) NULL  ,
   DATEDEBSAISON DATE NULL  ,
   DATEFINSAISON DATE NULL  
   , PRIMARY KEY (CODESAISON) 
 ) 
 comment = "";

# -----------------------------------------------------------------------------
#       TABLE : RESA
# -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS RESA
 (
   NOHEB INTEGER(4) NOT NULL  ,
   DATEDEBSEM DATE NOT NULL  ,
   NOVILLAGEOIS INTEGER(5) NOT NULL  ,
   CODEETATRESA CHAR(2) NOT NULL  ,
   DATERESA DATE NULL  ,
   DATEACCUSERECEPT DATE NULL  ,
   DATEARRHES DATE NULL  ,
   MONTANTARRHES DECIMAL(7,2) NULL  ,
   NBOCCUPANT INTEGER(2) NULL  ,
   PRIXRESA DECIMAL(7,2) NULL  
   , PRIMARY KEY (NOHEB,DATEDEBSEM) 
 ) 
 comment = "";

# -----------------------------------------------------------------------------
#       INDEX DE LA TABLE RESA
# -----------------------------------------------------------------------------


CREATE  INDEX I_FK_RESA_VILLAGEOIS
     ON RESA (NOVILLAGEOIS ASC);

CREATE  INDEX I_FK_RESA_SEMAINE
     ON RESA (DATEDEBSEM ASC);

CREATE  INDEX I_FK_RESA_HEBERGEMENT
     ON RESA (NOHEB ASC);

CREATE  INDEX I_FK_RESA_ETAT_RESA
     ON RESA (CODEETATRESA ASC);

# -----------------------------------------------------------------------------
#       TABLE : SEMAINE
# -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS SEMAINE
 (
   DATEDEBSEM DATE NOT NULL  ,
   CODESAISON CHAR(2) NOT NULL  ,
   DATEFINSEM DATE NULL  
   , PRIMARY KEY (DATEDEBSEM) 
 ) 
 comment = "";

# -----------------------------------------------------------------------------
#       INDEX DE LA TABLE SEMAINE
# -----------------------------------------------------------------------------


CREATE  INDEX I_FK_SEMAINE_SAISON
     ON SEMAINE (CODESAISON ASC);

# -----------------------------------------------------------------------------
#       TABLE : TYPE_HEB
# -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS TYPE_HEB
 (
   CODETYPEHEB CHAR(5) NOT NULL  ,
   NOMTYPEHEB CHAR(30) NULL  
   , PRIMARY KEY (CODETYPEHEB) 
 ) 
 comment = "";

# -----------------------------------------------------------------------------
#       TABLE : VILLAGEOIS
# -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS VILLAGEOIS
 (
   NOVILLAGEOIS INTEGER(5) NOT NULL  ,
   USER CHAR(8) NOT NULL  ,
   NOMVILLAGEOIS CHAR(40) NULL  ,
   PRENOMVILLAGEOIS CHAR(30) NULL  ,
   ADRMAIL CHAR(50) NULL  ,
   NOTEL CHAR(15) NULL  ,
   NOPORT CHAR(15) NULL  
   , PRIMARY KEY (NOVILLAGEOIS) 
 ) 
 comment = "";

# -----------------------------------------------------------------------------
#       INDEX DE LA TABLE VILLAGEOIS
# -----------------------------------------------------------------------------


CREATE UNIQUE INDEX I_FK_VILLAGEOIS_COMPTE
     ON VILLAGEOIS (USER ASC);

# -----------------------------------------------------------------------------
#       TABLE : COMPTE
# -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS COMPTE
 (
   USER CHAR(8) NOT NULL  ,
   MDP CHAR(10) NULL  ,
   NOMCOMPTE CHAR(40) NULL  ,
   PRENOMCOMPTE CHAR(30) NULL  ,
   DATEINSCRIP DATE NULL  ,
   DATESUPPRESSION DATE NULL  ,
   TYPECOMPTE CHAR(3) NULL       CHECK (TYPECOMPTE in ("AD","VIL","AVV"))
   , PRIMARY KEY (USER) 
 ) 
 comment = "";

# -----------------------------------------------------------------------------
#       TABLE : TARIF
# -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS TARIF
 (
   NOHEB INTEGER(4) NOT NULL  ,
   CODESAISON CHAR(2) NOT NULL  ,
   PRIXHEB DECIMAL(7,2) NULL  
   , PRIMARY KEY (NOHEB,CODESAISON) 
 ) 
 comment = "";

# -----------------------------------------------------------------------------
#       INDEX DE LA TABLE TARIF
# -----------------------------------------------------------------------------


CREATE  INDEX I_FK_TARIF_HEBERGEMENT
     ON TARIF (NOHEB ASC);

CREATE  INDEX I_FK_TARIF_SAISON
     ON TARIF (CODESAISON ASC);


# -----------------------------------------------------------------------------
#       CREATION DES REFERENCES DE TABLE
# -----------------------------------------------------------------------------


ALTER TABLE HEBERGEMENT 
  ADD FOREIGN KEY FK_HEBERGEMENT_TYPE_HEB (CODETYPEHEB)
      REFERENCES TYPE_HEB (CODETYPEHEB) ;


ALTER TABLE RESA 
  ADD FOREIGN KEY FK_RESA_VILLAGEOIS (NOVILLAGEOIS)
      REFERENCES VILLAGEOIS (NOVILLAGEOIS) ;


ALTER TABLE RESA 
  ADD FOREIGN KEY FK_RESA_SEMAINE (DATEDEBSEM)
      REFERENCES SEMAINE (DATEDEBSEM) ;


ALTER TABLE RESA 
  ADD FOREIGN KEY FK_RESA_HEBERGEMENT (NOHEB)
      REFERENCES HEBERGEMENT (NOHEB) ;


ALTER TABLE RESA 
  ADD FOREIGN KEY FK_RESA_ETAT_RESA (CODEETATRESA)
      REFERENCES ETAT_RESA (CODEETATRESA) ;


ALTER TABLE SEMAINE 
  ADD FOREIGN KEY FK_SEMAINE_SAISON (CODESAISON)
      REFERENCES SAISON (CODESAISON) ;


ALTER TABLE VILLAGEOIS 
  ADD FOREIGN KEY FK_VILLAGEOIS_COMPTE (USER)
      REFERENCES COMPTE (USER) ;


ALTER TABLE TARIF 
  ADD FOREIGN KEY FK_TARIF_HEBERGEMENT (NOHEB)
      REFERENCES HEBERGEMENT (NOHEB) ;


ALTER TABLE TARIF 
  ADD FOREIGN KEY FK_TARIF_SAISON (CODESAISON)
      REFERENCES SAISON (CODESAISON) ;

