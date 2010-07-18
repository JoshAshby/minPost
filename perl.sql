-- phpMyAdmin SQL Dump
-- version 3.2.4
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Jul 18, 2010 at 10:00 AM
-- Server version: 5.1.41
-- PHP Version: 5.3.1

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `perl`
--

-- --------------------------------------------------------

--
-- Table structure for table `pl_color`
--

CREATE TABLE IF NOT EXISTS `pl_color` (
  `name` text NOT NULL,
  `color` text NOT NULL,
  `round` text NOT NULL,
  `form` text NOT NULL,
  `text_color` text NOT NULL,
  `align` text NOT NULL,
  `no_show` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pl_color`
--

INSERT INTO `pl_color` (`name`, `color`, `round`, `form`, `text_color`, `align`, `no_show`) VALUES
('link', 'grey', 'bottom', 'yes', 'white', 'left', 0),
('top', 'grey', 'top', 'yes', 'white', 'left', 1),
('content', 'grey', 'top', 'yes', 'white', 'left', 0);

-- --------------------------------------------------------

--
-- Table structure for table `pl_content`
--

CREATE TABLE IF NOT EXISTS `pl_content` (
  `id` int(11) NOT NULL,
  `date` date NOT NULL,
  `title` text NOT NULL,
  `name` text NOT NULL,
  `post` text NOT NULL,
  KEY `id` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pl_content`
--

INSERT INTO `pl_content` (`id`, `date`, `title`, `name`, `post`) VALUES
(2, '2010-07-17', 'Testing welcome', 'Josh Ashby', 'The sites now powered by Perl, and MySQL to bring you these posts, and the comments with some badass (not really) jquery action and a highly modded (again only partially) bluetrip css framework file. Hope you enjoy!          ');

-- --------------------------------------------------------

--
-- Table structure for table `pl_db`
--

CREATE TABLE IF NOT EXISTS `pl_db` (
  `id` int(11) NOT NULL,
  `date` date NOT NULL,
  `name` text NOT NULL,
  `email` text NOT NULL,
  `post` text NOT NULL,
  `postid` int(11) NOT NULL,
  KEY `date` (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pl_db`
--


-- --------------------------------------------------------

--
-- Table structure for table `pl_links`
--

CREATE TABLE IF NOT EXISTS `pl_links` (
  `id` int(11) NOT NULL,
  `link` text NOT NULL,
  `linkname` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pl_links`
--

INSERT INTO `pl_links` (`id`, `link`, `linkname`) VALUES
(5, '#', 'another link'),
(8, '#', 'linking'),
(7, './', 'testing');

-- --------------------------------------------------------

--
-- Table structure for table `pl_login`
--

CREATE TABLE IF NOT EXISTS `pl_login` (
  `id` int(11) NOT NULL,
  `pass` text NOT NULL,
  `salt` text NOT NULL,
  `user` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pl_login`
--

INSERT INTO `pl_login` (`id`, `pass`, `salt`, `user`) VALUES
(0, '$1$mmygLDNq$qd30yIqoihqO6Vg/GVlwj.', 'mmygLDNq', 'Josh Ashby');

-- --------------------------------------------------------

--
-- Table structure for table `pl_site`
--

CREATE TABLE IF NOT EXISTS `pl_site` (
  `id` int(11) NOT NULL,
  `title` text NOT NULL,
  `align` text NOT NULL,
  `photo` text NOT NULL,
  `color` text NOT NULL,
  `round` text NOT NULL,
  `form` text NOT NULL,
  `box_round` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pl_site`
--

INSERT INTO `pl_site` (`id`, `title`, `align`, `photo`, `color`, `round`, `form`, `box_round`) VALUES
(0, 'Test Page', 'right', 'images/headers/header13.jpg', 'white', '', 'yes', 'right');
