using Nancy;
using Nancy.TinyIoc;
using OneTruePath.Domain;

namespace OneTruePath.API
{
    public class Bootstrapper : DefaultNancyBootstrapper
    {
        // The bootstrapper enables you to reconfigure the composition of the framework,
        // by overriding the various methods and properties.
        // For more information https://github.com/NancyFx/Nancy/wiki/Bootstrapper
        protected override void ConfigureApplicationContainer(TinyIoCContainer container)
        {
            container.Register<IStoryNavigator, StoryNavigator>().AsMultiInstance();
        }
    }
}