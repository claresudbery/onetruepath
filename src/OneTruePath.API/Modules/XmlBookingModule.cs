using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Nancy;

namespace OneTruePath.API.Modules
{
    public class XmlBookingModule : NancyModule
    {
        public XmlBookingModule()
        {
            Get["/xmlbooking"] = parameters =>
            {
                var xmlBooking = XmlBookingTest();

                //return "clare's xmlbooking";

                return JsonConvert.SerializeObject(xmlBooking.Errors.Count() > 0 ? (object)xmlBooking.Errors : xmlBooking);
                //return xmlBooking;
            };
        }

        //private BookingDetail CreateBookingDetailFromXml()
        //{
        ////string jsonFileName = ConfigurationManager.AppSettings["jsonFileName"];
        //string xmlFilePath = System.AppDomain.CurrentDomain.BaseDirectory;

        ////using (StreamReader file = File.OpenText(jsonFilePath + "\\" + jsonFileName))
        //XDocument sourceXml = new XDocument();
        //XDocument doc = XDocument.Load(xmlFilePath + "\\" + "XMLBooking-original.xml");
        //BookingDetail result = (BookingDetail)(doc.Element("BookingDetail").Value);

        //List<BookingDetail> result = (from o in doc.Elements()
        //                              select new BookingDetail
        //                        {
        //                            User = o.Element("user").Value,
        //                            Session = o.Element("session").Value
        //                        }).ToList();

        //return result;
        //}

        private BookingXML XmlBookingTest()
        {
            // 1. Changed room cost - didn't work
            // 2. Changed cardholder details - didn't work
            // 3. Changed BookingDetail details - didn't work
            // 4. Tried lower cost - didn't work (but got sensible error re price too low)
            // 5. Changed bed type to t instead of d - didn't work
            // 6. Got rid of smoking attribute on room

            var guest = new BookingUser
            {
                Title = "Miss",
                Initials = "J",
                Surname = "Test",
                Email = "abc@email.com",
                Postcode = "mm991ff",
                Tel = "xxxxxxxx",
                //SendEmailConfirmation = "true"
            };

            var booker = new BookingUser
            {
                Title = "mr",
                Initials = "J",
                Surname = "Test",
                Email = "email@email.com",
                Postcode = "ss57bbq",
                Tel = "xxxxxxxx",
                CountryOfResidence = "1",
                SendEmailConfirmation = "true",
                Address1 = "2 Cheetham Hill Road",
                Town = "Manchester"
            };

            var paymentCard = new BookingCard
            {
                CardHolderName = "MR J SMITH", // "Test Card", // !!!
                CardType = "2", // "1", // !!!
                CardNumber = "4444333322221111",
                ExpiryDate = "05/16",
                IssueNumberOrStartDate = "1", // "", // !!!
                SecurityCode = "333" // "753" // !!!
            };

            var bookingDetail = new BookingDetail
            {
                SpecialRequests = "Room on second floor",
                ReservationType = "l", // "", // !!!
                FromHotel = "false",
                Language = "1", // "", // !!!
                Unbranded = true,
                //SendHotelNotification = false, // !!!
                //DoNotBook = "false", // !!!
                //AutoReferralBooking = false, // !!!
                //ArrivalTime = "18:00", // !!!

                Guest = guest,
                Booker = booker,
                PaymentCard = paymentCard,
                Rooms = new BookingRoom[1]
                //Rooms = new BookingRoom[2]
            };

            var room1 = new BookingRoom
            {
                Id = "6188690",
                GuestTitle = "Mr",
                GuestInitials = "J",
                GuestSurname = "Smith",
                Adults = "2",
                Children = "0",
                BedType = "t", // "d", // !!!
                //Smoking = "false", // !!!
                Cost = "7.22" // "7.35" // !!!
            };
            bookingDetail.Rooms[0] = room1;

            //var room2 = new BookingRoom
            //{
            //    Id = "4337322",
            //    GuestTitle = "Mrs",
            //    GuestInitials = "J",
            //    GuestSurname = "Smithy",
            //    Adults = "2",
            //    Children = "1",
            //    BedType = "t",
            //    Cost = "300"
            //};
            //bookingDetail.Rooms[1] = room2;

            var partner = new BookingPartner
            {
                Id = "16514",
                Username = "harriet@carboncreative.net",
                Password = "p9ABn5j3Y",
                Value = ""
            };
            bookingDetail.Partner = partner;

            //bookingDetail.HotelId = "265785",
            bookingDetail.HotelId = "235128";
            bookingDetail.ArrivalDate = "21/02/2016";
            bookingDetail.Nights = "1";
            bookingDetail.Currency = "GBP";
            //bookingDetail.FromWhiteLabel = null; // !!!
            //bookingDetail.SmokingRoom = "false";

            var bookingService = new local.XmlBookingService.XmlBooking();
            BookingXML actualBooking = bookingService.makeBooking(bookingDetail);

            return actualBooking;
        }
    }
}