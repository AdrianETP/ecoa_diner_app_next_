USE ecoa_diner;
# Queries DML -- Datos extra
INSERT IGNORE INTO Premio VALUES
("CPN1",1,"Coupon","Coupon de Chili's"),
("GFTC1",5,"GiftCard","Giftcard de Amazon"),
("CPN2",2,"Coupon","Coupon de Starbucks"),
("CINE1",3,"Entrada de cine","Entrada para 2 personas en Cinemex"),
("GFTC2",4,"GiftCard","Giftcard de iTunes"),
("BOOK1",6,"Libro","Libro de su elección hasta $500 MXN"),
("MUS1",7,"Membresía","Membresía de Spotify por 3 meses");

INSERT IGNORE INTO Encuesta VALUES
("E1","202311","Ecoa Agosto-Diciembre 2023", current_date(), current_date(),0);


