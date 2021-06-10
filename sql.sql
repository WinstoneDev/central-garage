CREATE TABLE `garage` (
  `id` int(11) NOT NULL,
  `owner` varchar(255) DEFAULT NULL,
  `vehicle` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `plate` varchar(50) DEFAULT NULL,
  `properties` longtext DEFAULT NULL,
  `stored` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `garage`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;