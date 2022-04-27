-- Keep a log of any SQL queries you execute as you solve the mystery.

--starting with seeing the tables
.tables;

--starting with searching the crime_scene_reports as the problem suggests
SELECT id,description FROM crime_scene_reports WHERE (year = 2021 AND day = 28 AND month = 7 AND street = "Humphrey Street");
--id 295 | Theft of the CS50 duck took place at <10:15am> at the Humphrey Street bakery. Interviews were conducted today with <three witnesses>
--         who were <present at the time> - each of their interview transcripts mentions the bakery.
--id 297 | Littering took place <at 16:36 (4:36 PM)>. No known witnesses.

--checking the interviews from the day of the theft
SELECT id,name,transcript FROM interviews WHERE (year = 2021 AND day = 28 AND month = 7);
--id 161, Ruth    | Sometime within <TEN MINUTES> of the theft, I saw the thief get into a car in the bakery parking lot and drive away. If you
--                  have <SECURITY FOOTAGE> from the '<EMMAS BAKERY PARKING LOT>, you might want to look for cars that left the parking lot in that time frame.
--id 162, Eugene  | I don't know the thief's name, but it was someone I recognized. Earlier this morning <BEFORE 10:15 AM>, before I arrived at "EMMA's bakery", I was walking
--                  by the <ATM ON LEGGETT STREET> and saw the thief there withdrawing some money.
--id 163, Raymond | As the thief was leaving the bakery, they called someone who talked to them for <LESS THAN 60 SECONDS>. In the call, I heard the thief
--                  say that they were planning to take the <EARLIEST FLIGHT> out of Fiftyville <tomorrow July 29, 2021>. The thief then asked the person
--                  on the other end of the phone to purchase the flight ticket. <ACCOMPLICE BOUGHT THE FLIGHT>
--id 193, Emma    | I'm the bakery owner, and soemone came in, suspiciously whispering into a <PHONE FOR 30 MINUTES>. They <NEVER BOUGHT ANYTHING>.

--checking LEGGETT STREET ATM to see withdrawals before 10:15 AM
SELECT account_number FROM atm_transactions WHERE (year = 2021 AND month = 7 AND day = 28 AND atm_location ="Leggett Street" AND transaction_type = "withdraw");
--id 246, account_num #28500762, amount $48
--id 264, account_num #28296815, amount $20
--id 266, account_num #76054385, amount $60
--id 267, account_num #49610011, amount $50
--id 269, account_num #16153065, amount $80
--id 288, account_num #25506511, amount $20
--id 313, account_num #81061156, amount $30
--id 336, account_num #26013199, amount $35

--checking LEGGETT STREET for any other crimes that day to see if any witness might mention something else they saw
SELECT id,description FROM crime_scene_reports WHERE (year = 2021 AND day = 28 AND month = 7 AND street = "Leggett Street");
--NONE

--Connecting the bank account numbers from that day in question with the person_id and people.id's along with name, phone number, passport, license plate
SELECT name, phone_number, passport_number, license_plate FROM people WHERE id IN
    (SELECT person_id FROM bank_accounts WHERE account_number IN
    (SELECT account_number FROM atm_transactions WHERE
    (year = 2021 AND month = 7 AND day = 28 AND atm_location ="Leggett Street" AND transaction_type = "withdraw")));

--  Name   |  Phone Number  |  Passport  | License
-- Kenny   | (826) 555-1652 | 9878712108 | 30G67EN
-- Iman    | (829) 555-5269 | 7049073643 | L93JTIZ
-- Benista | (338) 555-6650 | 9586786673 | 8X428L0
-- Taylor  | (286) 555-6063 | 1988161715 | 1106N58
-- Brooke  | (122) 555-4581 | 4408372428 | QX4YZN3
-- Luc     | (389) 555-5198 | 8496433585 | 4328GD8
-- Diana   | (770) 555-1861 | 3592750733 | 322W7JE
-- Bruce   | (367) 555-5533 | 5773159633 | 94KL13X

--Checking the security footage for the cars the left the lot between 10:15 and 10:25
SELECT license_plate FROM bakery_security_logs WHERE (year = 2021 AND month = 7 AND day = 28 AND hour = 10 AND minute <= 25 AND minute >= 15 AND activity = "exit");

-- license
-- 5P2BI95
-- 94KL13X
-- 6P58WS2
-- 4328GD8
-- G412CB7
-- L93JTIZ
-- 322W7JE
-- 0NTHK55

--Match the license plates of the people who withdrew money and the ones who left the bakery at the given time
SELECT name, phone_number, passport_number FROM people WHERE id IN
    (SELECT person_id FROM bank_accounts WHERE account_number IN
    (SELECT account_number FROM atm_transactions WHERE
    (year = 2021 AND month = 7 AND day = 28 AND atm_location ="Leggett Street" AND transaction_type = "withdraw")))
    AND license_plate IN (SELECT license_plate FROM bakery_security_logs WHERE
    (year = 2021 AND month = 7 AND day = 28 AND hour = 10 AND minute <= 25 AND minute >= 15 AND activity = "exit"));

-- name  |  Phone Number  |  passport  |
-- Iman  | (829) 555-5269 | 7049073643 |
-- Luca  | (389) 555-5198 | 8496433585 |
-- Diana | (770) 555-1861 | 3592750733 |
-- Bruce | (367) 555-5533 | 5773159633 |

--Check all the phone calls for that day with durations under 60 seconds
SELECT caller, receiver FROM phone_calls WHERE year = 2021 AND month = 7 AND day = 28 AND duration < 60;

--Way too many numbers to type out so im not writing them all, ill write the compared ones

--Compare the phone numbers of the caller with the previous numbers of those who withdrew money at LEGGETT street and left the bakery after robbery
SELECT name, phone_number, passport_number FROM people WHERE id IN
    (SELECT person_id FROM bank_accounts WHERE account_number IN
    (SELECT account_number FROM atm_transactions WHERE
    (year = 2021 AND month = 7 AND day = 28 AND atm_location ="Leggett Street" AND transaction_type = "withdraw")))
    AND license_plate IN (SELECT license_plate FROM bakery_security_logs WHERE
    (year = 2021 AND month = 7 AND day = 28 AND hour = 10 AND minute <= 25 AND minute >= 15 AND activity = "exit"))
    AND phone_number IN (SELECT caller FROM phone_calls WHERE year = 2021 AND month = 7 AND day = 28 AND duration < 60);

-- name  |  Phone Number  |  passport  |
-- Diana | (770) 555-1861 | 3592750733 |
-- Bruce | (367) 555-5533 | 5773159633 |

--Now compare the passports to those who took earliest flight the next day
SELECT id FROM flights WHERE year = 2021 AND month = 7 AND day = 29 ORDER BY HOUR LIMIT 1;

--  passports
-- 7214083635
-- 1695452385
-- 5773159633
-- 1540955065
-- 8294398571
-- 1988161715
-- 9878712108
-- 8496433585

--Then compare it all to get the name of our thief
SELECT name, phone_number FROM people WHERE id IN
    (SELECT person_id FROM bank_accounts WHERE account_number IN
    (SELECT account_number FROM atm_transactions WHERE
    (year = 2021 AND month = 7 AND day = 28 AND atm_location ="Leggett Street" AND transaction_type = "withdraw")))
    AND license_plate IN (SELECT license_plate FROM bakery_security_logs WHERE
    (year = 2021 AND month = 7 AND day = 28 AND hour = 10 AND minute <= 25 AND minute >= 15 AND activity = "exit"))
    AND phone_number IN (SELECT caller FROM phone_calls WHERE year = 2021 AND month = 7 AND day = 28 AND duration < 60)
    AND passport_number IN (SELECT passport_number FROM passengers
    WHERE flight_id = (SELECT id FROM flights WHERE year = 2021 AND month = 7 AND day = 29 ORDER BY HOUR LIMIT 1));

--Bruce! Found the thief!

--Now compare Bruces phone number to the person he called
SELECT name FROM people WHERE phone_number IN (SELECT receiver FROM phone_calls WHERE caller = "(367) 555-5533"
    AND year = 2021 AND month = 7 AND day = 28 AND duration < 60);

--Robin! Found the accomplice!

--Now get the flights desination airport and city!
SELECT city FROM airports WHERE id IN (SELECT destination_airport_id FROM flights WHERE origin_airport_id = 8 AND year = 2021 AND month = 7 AND day = 29 ORDER BY HOUR LIMIT 1);

--New York City! We gottem!
