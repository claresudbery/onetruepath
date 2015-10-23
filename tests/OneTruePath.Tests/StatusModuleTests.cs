using NUnit.Framework;
using Nancy;
using Nancy.Testing;
using OneTruePath.API.Modules;

namespace OneTruePath.Tests
{
    [TestFixture]
    public class StatusModuleTests
    {
        [Test]
        public void ShouldRespondToStatusRequests()
        {
            // Arrange
            var browser = new Browser(with => with.Module(new StatusModule()));

            // Act
            var response = browser.Get("/status");

            // Assert
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK));
        }
    }
}