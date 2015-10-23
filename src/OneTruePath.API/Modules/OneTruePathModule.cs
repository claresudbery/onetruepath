using Nancy;
using OneTruePath.Domain;

namespace OneTruePath.API.Modules
{
    public class OneTruePathModule : NancyModule
    {
        public OneTruePathModule(IStoryNavigator storyNavigator)
        {
            Get["/truepath"] = parameters =>
            {
                string result = storyNavigator.Refresh();
                return result;
            };

            Get["/truepath/-"] = parameters =>
            {
                return storyNavigator.GoBack();
            };

            Get["/truepath/1"] = parameters =>
            {
                string result = storyNavigator.GoForward(1);
                return result;
            };

            Get["/truepath/2"] = parameters =>
            {
                string result = storyNavigator.GoForward(2);
                return result;
            };

            Get["/truepath/3"] = parameters =>
            {
                string result = storyNavigator.GoForward(3);
                return result;
            };
        }
    }
}