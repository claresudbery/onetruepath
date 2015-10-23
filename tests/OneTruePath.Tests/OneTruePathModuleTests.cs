using NUnit.Framework;
using Nancy;
using Nancy.Testing;
using OneTruePath.API.Modules;
using OneTruePath.Domain;
using Rhino.Mocks;

namespace OneTruePath.Tests
{
    [TestFixture]
    public class OneTruePathModuleTests
    {
        [Test]
        public void ShouldRespondToTruePathRequests()
        {
            // Arrange
            var fakeTruePath = MockRepository.GenerateStub<IStoryNavigator>();
            var browser = new Browser(with => with.Module(new OneTruePathModule(fakeTruePath)));

            // Act
            var response = browser.Get("/truepath", with =>
            {
            });

            // Assert
            Assert.That(response.StatusCode, Is.EqualTo(HttpStatusCode.OK));
        }
    }
}